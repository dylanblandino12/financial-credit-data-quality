# financial-credit-data-quality
End-to-end data quality framework for financial credit risk data using SQL, Python and Power BI.

## Dataset Overview
- Dataset: Lending Club Loan Data (sampled)
- Layer: RAW
- Each row represents a loan
- Potential candidate keys identified: id (loan-level), member_id (customer-level)
- Uniqueness not validated during profiling

## Schema Overview
- Schema documented using BigQuery INFORMATION_SCHEMA.
- Dataset includes numeric, categorical, and boolean attributes.
- Nullable fields identified for downstream data quality assessment.
