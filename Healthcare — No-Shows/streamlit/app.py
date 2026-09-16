import streamlit as st
import pandas as pd
import altair as alt

from sqlalchemy import create_engine
from urllib.parse import quote_plus


# --------------------------------------------------
# PAGE CONFIG
# --------------------------------------------------

st.set_page_config(
    page_title="Healthcare No-Show Analytics",
    page_icon="🏥",
    layout="wide",
    initial_sidebar_state="expanded"
)


# --------------------------------------------------
# DATABASE CONNECTION
# --------------------------------------------------

server = st.secrets["database"]["server"]
database = st.secrets["database"]["database"]
username = st.secrets["database"]["username"]
password = st.secrets["database"]["password"]

connection_string = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    f"SERVER={server};"
    f"DATABASE={database};"
    f"UID={username};"
    f"PWD={password};"
    "Encrypt=yes;"
    "TrustServerCertificate=no;"
    "Connection Timeout=60;"
)

connection_url = quote_plus(connection_string)

engine = create_engine(
    f"mssql+pyodbc:///?odbc_connect={connection_url}"
)


# --------------------------------------------------
# LOAD DATA
# --------------------------------------------------

@st.cache_data(ttl=600)
def load_data():

    overview = pd.read_sql(
        "SELECT * FROM dbo.vw_NoShowOverview",
        engine
    )

    waiting = pd.read_sql(
        "SELECT * FROM dbo.vw_NoShowByWaitingGroup",
        engine
    )

    neighbourhood = pd.read_sql(
        "SELECT * FROM dbo.vw_NoShowByNeighbourhood",
        engine
    )

    sms = pd.read_sql(
        "SELECT * FROM dbo.vw_NoShowBySMS",
        engine
    )

    priority = pd.read_sql(
        "SELECT * FROM dbo.vw_CommunicationPriority",
        engine
    )

    return overview, waiting, neighbourhood, sms, priority


overview, waiting, neighbourhood, sms, priority = load_data()


# --------------------------------------------------
# SIDEBAR
# --------------------------------------------------

with st.sidebar:

    st.title("Healthcare Analytics")

    st.markdown(
        """
        **Business goal**

        Identify operational patterns associated with
        appointment absenteeism and support actions that
        reduce lost healthcare capacity.
        """
    )

    st.divider()

    st.markdown("### Dataset")

    st.write(
        "Public healthcare appointment records enriched "
        "with neighbourhood-level IBGE income data."
    )

    st.markdown("### Analytical Grain")

    st.write(
        "**One row = one scheduled appointment**"
    )

    st.divider()

    st.caption(
        "Income variables represent neighbourhood-level "
        "context and should not be interpreted as individual "
        "patient income."
    )


# --------------------------------------------------
# HEADER
# --------------------------------------------------

st.title("Healthcare Appointment No-Show Analytics")

st.markdown(
    """
    Operational dashboard for monitoring appointment absenteeism,
    scheduling lead time, neighbourhood patterns and communication
    opportunities.
    """
)

st.divider()


# --------------------------------------------------
# OVERVIEW KPIs
# --------------------------------------------------

row = overview.iloc[0]

col1, col2, col3, col4 = st.columns(4)

col1.metric(
    "Appointments",
    f"{int(row['TotalAppointments']):,}"
)

col2.metric(
    "No-Shows",
    f"{int(row['TotalNoShows']):,}"
)

col3.metric(
    "No-Show Rate",
    f"{float(row['NoShowRate']):.1f}%"
)

col4.metric(
    "Average Waiting Time",
    f"{float(row['AverageWaitingDays']):.1f} days"
)

st.info(
    """
    **Key finding:** Scheduling lead time is the strongest
    operational signal identified in the analysis. Same-day
    appointments present substantially lower absenteeism than
    appointments scheduled several weeks in advance.
    """
)


# --------------------------------------------------
# TABS
# --------------------------------------------------

tab1, tab2, tab3 = st.tabs(
    [
        "Executive Overview",
        "Operational Drivers",
        "Communication & Recovery"
    ]
)


# ==================================================
# TAB 1 — EXECUTIVE OVERVIEW
# ==================================================

with tab1:

    st.subheader("Executive Summary")

    left, right = st.columns(2)

    with left:

        st.markdown(
            """
            ### Main Findings

            - Scheduling lead time shows the strongest
              association with no-show behaviour.

            - Weekday differences are relatively small.

            - Higher neighbourhood income is associated with
              slightly lower absenteeism, although the
              relationship is weak.

            - Repeat observed appointments show a slightly
              higher no-show rate than first observed
              appointments.

            - SMS results must be interpreted together with
              scheduling lead time.
            """
        )

    with right:

        st.markdown(
            """
            ### Operational Interpretation

            The strongest opportunity appears to be in
            appointments scheduled further in advance.

            Communication strategies can then be refined using:

            - appointment recurrence;
            - neighbourhood context;
            - SMS status;
            - volume of missed appointments.
            """
        )

    st.divider()

    st.subheader("Neighbourhoods with Largest No-Show Volume")

    top_volume = (
        neighbourhood
        .sort_values(
            "NoShows",
            ascending=False
        )
        .head(10)
    )

    neighbourhood_chart = (
        alt.Chart(top_volume)
        .mark_bar()
        .encode(
            x=alt.X(
                "NoShows:Q",
                title="No-Shows"
            ),
            y=alt.Y(
                "NeighbourhoodName:N",
                sort="-x",
                title=None
            ),
            color=alt.Color(
                "NoShows:Q",
                legend=None
            ),
            tooltip=[
                "NeighbourhoodName",
                "Appointments",
                "NoShows",
                alt.Tooltip(
                    "NoShowRate:Q",
                    format=".1f"
                )
            ]
        )
        .properties(
            height=400
        )
    )

    st.altair_chart(
        neighbourhood_chart,
        use_container_width=True
    )


# ==================================================
# TAB 2 — OPERATIONAL DRIVERS
# ==================================================

with tab2:

    st.subheader("Scheduling Lead Time")

    waiting_order = [
        "Same day",
        "1-2 days",
        "3-7 days",
        "8-14 days",
        "15-30 days",
        "31-60 days",
        "61+ days"
    ]

    waiting["WaitingGroup"] = pd.Categorical(
        waiting["WaitingGroup"],
        categories=waiting_order,
        ordered=True
    )

    waiting = waiting.sort_values(
        "WaitingGroup"
    )

    lead_chart = (
        alt.Chart(waiting)
        .mark_bar()
        .encode(
            x=alt.X(
                "WaitingGroup:N",
                sort=waiting_order,
                title="Scheduling Lead Time"
            ),
            y=alt.Y(
                "NoShowRate:Q",
                title="No-Show Rate (%)"
            ),
            color=alt.Color(
                "NoShowRate:Q",
                legend=None
            ),
            tooltip=[
                "WaitingGroup",
                "Appointments",
                "NoShows",
                alt.Tooltip(
                    "NoShowRate:Q",
                    format=".1f"
                ),
                alt.Tooltip(
                    "AverageWaitingDays:Q",
                    format=".1f"
                )
            ]
        )
        .properties(
            height=400
        )
    )

    text_labels = (
        alt.Chart(waiting)
        .mark_text(
            dy=-10,
            fontWeight="bold"
        )
        .encode(
            x=alt.X(
                "WaitingGroup:N",
                sort=waiting_order
            ),
            y="NoShowRate:Q",
            text=alt.Text(
                "NoShowRate:Q",
                format=".1f"
            )
        )
    )

    st.altair_chart(
        lead_chart + text_labels,
        use_container_width=True
    )

    st.caption(
        "Values represent observed associations and do not "
        "establish that longer waiting time causes absenteeism."
    )

    st.divider()

    st.subheader("Neighbourhood No-Show Rate")

    minimum_volume = st.slider(
        "Minimum appointments per neighbourhood",
        min_value=50,
        max_value=1000,
        value=100,
        step=50
    )

    filtered_neighbourhood = (
        neighbourhood[
            neighbourhood["Appointments"]
            >= minimum_volume
        ]
        .sort_values(
            "NoShowRate",
            ascending=False
        )
        .head(15)
    )

    rate_chart = (
        alt.Chart(filtered_neighbourhood)
        .mark_bar()
        .encode(
            x=alt.X(
                "NoShowRate:Q",
                title="No-Show Rate (%)"
            ),
            y=alt.Y(
                "NeighbourhoodName:N",
                sort="-x",
                title=None
            ),
            color=alt.Color(
                "NoShowRate:Q",
                legend=None
            ),
            tooltip=[
                "NeighbourhoodName",
                "Appointments",
                "NoShows",
                alt.Tooltip(
                    "NoShowRate:Q",
                    format=".1f"
                ),
                "IncomeMedian",
                "IncomeGroup"
            ]
        )
        .properties(
            height=500
        )
    )

    st.altair_chart(
        rate_chart,
        use_container_width=True
    )


# ==================================================
# TAB 3 — COMMUNICATION & RECOVERY
# ==================================================

with tab3:

    st.subheader("SMS Reminder Analysis")

    st.warning(
        """
        **Interpret carefully:** SMS recipients show a higher
        crude no-show rate because SMS is concentrated among
        appointments with longer scheduling lead times.

        Within comparable waiting-time groups, SMS recipients
        consistently show lower absenteeism.
        """
    )

    st.dataframe(
        sms[
            [
                "SMSStatus",
                "Appointments",
                "NoShows",
                "NoShowRate",
                "AverageWaitingDays"
            ]
        ],
        use_container_width=True,
        hide_index=True
    )

    st.divider()

    st.subheader("Potentially Recoverable Capacity")

    total_no_shows = int(
        row["TotalNoShows"]
    )

    scenario = pd.DataFrame(
        {
            "Scenario": [
                "10% reduction",
                "20% reduction",
                "30% reduction"
            ],
            "Potentially Recovered Slots": [
                round(total_no_shows * 0.10),
                round(total_no_shows * 0.20),
                round(total_no_shows * 0.30)
            ]
        }
    )

    recovery_chart = (
        alt.Chart(scenario)
        .mark_bar()
        .encode(
            x=alt.X(
                "Scenario:N",
                title=None
            ),
            y=alt.Y(
                "Potentially Recovered Slots:Q",
                title="Potentially Recovered Slots"
            ),
            color=alt.Color(
                "Potentially Recovered Slots:Q",
                legend=None
            ),
            tooltip=[
                "Scenario",
                "Potentially Recovered Slots"
            ]
        )
        .properties(
            height=350
        )
    )

    recovery_labels = (
        alt.Chart(scenario)
        .mark_text(
            dy=-10,
            fontWeight="bold"
        )
        .encode(
            x="Scenario:N",
            y="Potentially Recovered Slots:Q",
            text="Potentially Recovered Slots:Q"
        )
    )

    st.altair_chart(
        recovery_chart + recovery_labels,
        use_container_width=True
    )

    st.caption(
        "These values represent hypothetical recoverable "
        "capacity rather than guaranteed additional care delivery."
    )

    st.divider()

    st.subheader(
        "Priority Communication Opportunities"
    )

    priority_filtered = (
        priority[
            (priority["SMSReceived"] == 0)
            &
            (priority["NoShowRate"] > 20.19)
        ]
        .sort_values(
            [
                "NoShows",
                "NoShowRate"
            ],
            ascending=[
                False,
                False
            ]
        )
    )

    st.dataframe(
        priority_filtered.head(15),
        use_container_width=True,
        hide_index=True
    )


# --------------------------------------------------
# METHODOLOGY
# --------------------------------------------------

st.divider()

with st.expander(
    "Methodology and analytical limitations"
):

    st.markdown(
        """
        - The analysis is observational and does not establish
          causal relationships.

        - Neighbourhood income represents area-level
          socioeconomic context, not individual patient income.

        - `ObservedVisitType` is a recurrence proxy derived from
          repeated `PatientId` observations and does not confirm
          clinical follow-up status.

        - The operational rule determining SMS eligibility is
          not available in the source dataset.

        - The dataset does not contain diagnosis, clinical
          severity, appointment specialty, transportation access,
          employment status or stated reasons for absence.

        - Recoverable capacity scenarios are estimates and depend
          on operational replacement processes.
        """
    )