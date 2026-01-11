# financial-credit-data-quality
End-to-end data quality framework for financial credit risk data using SQL, Python and Power BI.

## Project Overview
End-to-end data quality framework for financial credit risk data using SQL, Python and Power BI.

This project focuses on assessing data readiness and identifying data quality risks in loan application data prior to analytics or reporting use.

---

## Data Source
- Dataset: *Should This Loan be Approved or Denied?* (Kaggle)
- Table: `loan_applications`
- Layer: RAW
- Platform: Google BigQuery

A representative sample of the dataset is used for development and data quality assessment purposes.

---

## Data Profiling Approach
Initial data profiling was performed to understand dataset structure, granularity, schema, and identify early data quality risks before applying any validation rules.

The profiling process focused on:
- Granularity and record definition
- Identifier availability and uniqueness
- Data completeness
- Basic validity checks
- Cross-field consistency

---

## Dataset Overview
- Each row represents a **loan application**.
- A loan-level identifier (`LoanNr_ChkDgt`) is available and fully populated.
- The dataset supports traceability and uniqueness checks at the RAW layer.

---

## Schema Overview
- Schema documented using BigQuery `INFORMATION_SCHEMA`.
- Dataset contains a mix of numeric, categorical, boolean, and date fields.
- Multiple nullable fields were identified for downstream data quality assessment.

---

## Data Completeness (Initial Profiling)
- Completeness checks were performed on critical approval and disbursement fields.
- The loan identifier and core approval/disbursement attributes are fully populated.
- Missing values were identified in:
  - `MIS_Status`
  - `SBA_Appv`
- These gaps represent data quality risks for loan status reporting and SBA-related analysis.

---

## Basic Validity Checks
- Numeric fields (loan term, approved amounts, disbursement amounts) fall within valid ranges.
- A small number of records contain future approval or disbursement dates.
- 711 records have a positive disbursement amount but a missing disbursement date, indicating a notable validity issue affecting disbursement tracking.

---

## Consistency Checks
- A significant number of records show disbursement amounts exceeding approved amounts.
- Charge-off dates were found for loans not marked as charged-off, indicating status-to-date inconsistencies.
- No inconsistencies were found where SBA-approved amounts exceed total approved amounts.
- Consistency issues represent the **primary data quality risk** in the dataset.

---

## Data Quality Summary
- Total records analyzed: **299,990**
- Completeness issues: **1,380 records**
- Validity issues: **3 records**
- Consistency issues: **53,538 records**

The main data quality risk identified is **cross-field consistency**, rather than invalid individual values.

---

## Key Takeaways
- The dataset is structurally sound and contains a usable loan-level identifier.
- Individual field validity is strong with minimal out-of-range values.
- Cross-field inconsistencies between approval, disbursement, and status data pose the greatest risk.
- These findings provide a clear foundation for defining data quality KPIs, remediation priorities, and monitoring.

---

## Next
