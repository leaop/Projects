# CRM Data & AI Governance Lab

An end-to-end portfolio project that demonstrates how a synthetic CRM environment can be governed across **access, risk, data quality, metadata, privacy, lineage, stewardship, analytics, monitoring, and AI**.

## Project objective

The project answers a broader question than “who should be blocked from the CRM?”:

> **How can a CRM environment be designed, documented, monitored, and extended to AI while keeping data access explainable, traceable, privacy-aware, and governed?**

The work starts with exploratory analysis of CRM access events and progressively builds a governance framework around the data. The final architecture combines rule-based access governance, Data Quality controls, metadata and cataloging, privacy engineering, lineage, stewardship, an analytical star schema, Power BI monitoring, and an AI Governance extension.

## Why this project matters

Many governance projects are presented only as policy documents or only as dashboards. This project intentionally connects both sides:

- **technical controls** — Python, rule engines, quality checks, privacy transformations, analytical modeling;
- **governance artifacts** — rule catalogs, ownership, stewardship, RACI, issue workflows, lineage, classifications;
- **monitoring** — Power BI semantic model, KPIs, drill-through, governance operations;
- **AI Governance** — use-case inventory, AI risks, controls, human oversight, logging, incident management, and NIST AI RMF mapping.

## Project stages

| Stage | Notebook | Focus |
|---|---|---|
| 01 | `01_eda.ipynb` | Data discovery, profiling, access patterns, anomalies |
| 02 | `02_explanatory_analysis.ipynb` | Statistical association, thresholds, interpretable decision trees |
| 03 | `03_governance_rules.ipynb` | RBAC matrix, contextual risk, rule catalog, ALLOW/REVIEW/BLOCK |
| 04 | `04_data_quality_framework.ipynb` | DQ dimensions, rule catalog, pass/fail monitoring, remediation priority |
| 05 | `05_metadata_data_catalog.ipynb` | Business glossary, technical metadata, domains, owners, stewards, CDEs |
| 06 | `06_privacy_engineering.ipynb` | PII classification, minimization, masking, pseudonymization |
| 07 | `07_data_lineage_traceability.ipynb` | Source-to-target mapping, transformation registry, rule/KPI lineage |
| 08 | `08_governance_operating_model.ipynb` | RACI, issue workflows, policy exceptions, governance forums |
| 09 | `09_analytical_data_model.ipynb` | Star schema, fact/dimensions, referential integrity, analytical measures |
| 10 | `10_powerbi_governance_monitoring.ipynb` | DAX, report pages, slicers, drill-through, storytelling |
| 11 | `11_ai_governance_extension.ipynb` | AI use case, risk register, controls, oversight, logging, NIST mapping |
| 12 | `12_final_packaging.ipynb` | Repository documentation and portfolio packaging |

Executed versions of Stages 01–11 are available in `notebooks/executed/`.

## Governance architecture

```text
CRM / CUSTOMER DATA
        |
        v
DISCOVERY & PROFILING
        |
        +---- DATA QUALITY
        +---- METADATA & CATALOG
        +---- CLASSIFICATION
        |
        v
GOVERNANCE CONTROLS
        |
        +---- RBAC / ACCESS GOVERNANCE
        +---- CONTEXTUAL RISK
        +---- PRIVACY ENGINEERING
        +---- LINEAGE & TRACEABILITY
        |
        v
STEWARDSHIP & OPERATING MODEL
        |
        +---- OWNER / STEWARD
        +---- RACI
        +---- ISSUES / EXCEPTIONS
        +---- REVIEW CADENCE
        |
        v
ANALYTICAL STAR SCHEMA
        |
        v
POWER BI GOVERNANCE MONITORING
        |
        v
AI GOVERNANCE EXTENSION
```

## Core governance capabilities demonstrated

### Access Governance
The project distinguishes **functional authorization** from **contextual access risk**. A user may have a role-level permission while the final access request can still require review or blocking because of sensitivity, device type, anomaly score, failed logins, or other context.

### Data Quality
The Data Quality framework uses explicit rule IDs and dimensions such as completeness, validity, uniqueness, and consistency. Rules produce record-level flags, pass/fail rates, weighted quality scores, and remediation priority.

### Metadata & Catalog
Fields are enriched with business definitions, domains, proposed Data Owners and Data Stewards, sensitivity, criticality, source metadata, Data Quality dependencies, and governance-rule dependencies.

### Privacy Engineering
A synthetic customer layer demonstrates:
- direct vs. indirect identifiers;
- data minimization;
- masking;
- pseudonymization;
- generalization;
- creation of an analytics-safe customer layer.

### Lineage
The project documents:
- source-to-target mappings;
- transformation IDs;
- governance-rule dependencies;
- privacy-control dependencies;
- rule-to-KPI impact analysis.

### Stewardship & Operating Model
The project includes:
- Data Owner vs. Data Steward responsibilities;
- RACI;
- issue severity;
- Data Quality escalation;
- policy exception workflow;
- metadata review cadence;
- governance committee and forum cadence;
- governance decision log.

### Analytical Model
The monitoring layer follows a star-schema approach around `fact_access_event`, with dimensions for role, action, device, sensitivity, rule, risk, hour, region, and lead source.

### Power BI
The planned governance report contains seven pages:
1. Governance Overview
2. Access Governance
3. Risk & Security
4. Data Quality
5. Privacy Monitoring
6. Metadata & Lineage
7. Governance Operations

### AI Governance
The CRM AI Assistant extension adds:
- AI system inventory;
- AI actor model;
- risk taxonomy and risk register;
- risk-to-control mapping;
- action restrictions;
- human oversight;
- prompt/response logging;
- AI incident management;
- governance KPIs;
- conceptual mapping to the NIST AI RMF functions **GOVERN, MAP, MEASURE, and MANAGE**.

## Data

The main access dataset used by the notebooks is:

`Permission_Aware_CRM_Governance_Synthetic_50000.csv`

It is a synthetic CRM governance/access dataset obtained from Kaggle.

The original dataset is intentionally **not redistributed in this repository package** because its redistribution license is not documented here. Place your authorized copy in:

```text
data/raw/Permission_Aware_CRM_Governance_Synthetic_50000.csv
```

The notebooks currently reference the filename directly. You can either run them from the same directory as the CSV or update `DATA_PATH` to the path above.

Stage 06 also creates a fully synthetic customer dataset programmatically; no real customer PII is used.

## Repository structure

```text
crm-data-ai-governance/
├── README.md
├── requirements.txt
├── .gitignore
├── notebooks/
│   ├── 01_eda.ipynb
│   ├── ...
│   ├── 12_final_packaging.ipynb
│   └── executed/
├── data/
│   ├── raw/
│   └── processed/
├── governance/
│   ├── ai_governance/
│   ├── lineage/
│   └── operating_model/
├── models/
├── powerbi/
└── docs/
```

## How to run

Create a Python environment and install the project dependencies:

```bash
pip install -r requirements.txt
```

Then add the authorized CRM CSV to the project and run the notebooks in stage order.

Recommended environment:
- Python 3.11+
- JupyterLab or VS Code notebooks

## Key Python libraries

- pandas
- numpy
- matplotlib
- scipy
- scikit-learn
- hashlib from the Python standard library

## Power BI implementation

The semantic-model and report specification are documented in Stage 10 and in `powerbi/README.md`.

The report should use single-direction `1:*` relationships from dimensions to `fact_access_event`.

Core KPI examples:
- Total Access Events
- Proposed Block Rate
- Review Rate
- Critical Risk Events
- DQ Pass Rate
- High Sensitivity Access
- BYOD Access Events

## AI Governance reference

Stage 11 uses the **NIST AI Risk Management Framework (AI RMF 1.0)** as a conceptual reference. NIST describes AI RMF 1.0 as voluntary and use-case agnostic, and its Core is organized around **GOVERN, MAP, MEASURE, and MANAGE**. The project also references the **Generative AI Profile (NIST AI 600-1)** for GenAI-specific risk considerations.

As of 2026, NIST states that AI RMF 1.0 is being revised, so this repository does **not** claim formal certification or complete framework alignment.

## Limitations

- The project uses synthetic data.
- Governance policies and thresholds are project proposals, not production policies.
- Privacy labels are internal project classifications, not legal determinations.
- The original access dataset has no complete event timestamp.
- There is no production catalog, IAM, DLP, ticketing, or lineage platform integration.
- The Power BI report specification is provided, but the `.pbix` must be built in Power BI Desktop.
- The AI assistant is simulated and no production LLM is connected.
- No legal-compliance or NIST-certification claim is made.

## Skills demonstrated

**Data Governance:** data ownership, stewardship, CDEs, rule catalogs, governance operating models  
**Data Quality:** profiling, rule execution, quality dimensions, monitoring and remediation  
**Metadata Management:** business glossary, technical metadata, data catalog, classifications  
**Privacy Engineering:** minimization, masking, pseudonymization, privacy-safe analytical layers  
**Access Governance:** RBAC, contextual risk, rule priority, explainable access decisions  
**Lineage:** source-to-target mapping, transformation registry, rule/KPI traceability  
**Analytics Engineering:** Python, pandas, dimensional modeling, star schemas, KPI design  
**Power BI:** semantic-model design, DAX, report architecture, drill-through and monitoring  
**AI Governance:** AI inventories, risk/control mapping, human oversight, logging, incidents, NIST AI RMF concepts

## Portfolio summary

> Designed an end-to-end Data & AI Governance framework for a synthetic CRM environment, integrating access governance, contextual risk, Data Quality rules, metadata/catalog management, privacy engineering, lineage, stewardship, dimensional modeling, Power BI monitoring, and AI risk controls.

