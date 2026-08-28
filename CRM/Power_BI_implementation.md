# Power BI Implementation Guide

Use Stage 10 as the detailed report specification.

## Recommended pages

1. Governance Overview
2. Access Governance
3. Risk & Security
4. Data Quality
5. Privacy Monitoring
6. Metadata & Lineage
7. Governance Operations

## Relationship pattern

Use `1:*`, single-direction relationships from each access dimension to `fact_access_event`.

## Core measures

- Total Access Events
- Original Block Rate
- Proposed Block Rate
- Review Rate
- Allow Rate
- Critical Risk Events
- Average Contextual Risk Score
- Average Anomaly Score
- DQ Pass Rate
- BYOD Access Events
- High Sensitivity Access

## Final repository asset

After implementation, place screenshots or exported report images in this folder. A `.pbix` can also be stored here if repository size and organizational policy allow it.
