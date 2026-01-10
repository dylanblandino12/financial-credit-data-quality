-- =====================================
-- File: 01_basic_profiling.sql
-- Purpose: Perform initial data profiling to understand dataset structure,
--          granularity, schema, and identify early data quality risks
-- Dataset: Loan Application Dataset
-- Tool: Google BigQuery
-- =====================================

-- =====================================
-- Dataset Overview
-- =====================================
-- Total rows
SELECT
  COUNT(*) as total_loans
FROM
  `raw.loan_applications`;

--Total loans
SELECT
  COUNT(DISTINCT LoanNr_ChkDgt) as unique_loans
FROM
  `raw.loan_applications`;

-- Findings:
-- - The dataset contains 299,990 loan application records.
-- - Each row represents a single loan application.

--Check null values

SELECT 
  COUNT(*) AS null_loan_id_count
FROM `raw.loan_applications`
WHERE LoanNr_ChkDgt IS NULL;


-- Findings:
-- - LoanNr_ChkDgt contains 0 NULL values.
-- - Field is fully populated at the RAW layer.


-- =====================================
-- Schema Overview
-- =====================================

SELECT
  column_name,
  data_type,
  is_nullable
FROM `raw.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'loan_applications'
ORDER BY ordinal_position;

-- Findings:
-- - Schema documented using INFORMATION_SCHEMA for reproducibility.
-- - Dataset includes numeric, categorical, boolean, and date-like fields.
-- - Multiple nullable fields identified for downstream completeness checks.


-- Completeness for relevant columns
SELECT
  SUM(CASE WHEN LoanNr_ChkDgt IS NULL THEN 1 ELSE 0 END) AS loan_id_null_count,
  SUM(CASE WHEN ApprovalDate IS NULL THEN 1 ELSE 0 END) AS approval_date_null_count,
  SUM(CASE WHEN ApprovalFY IS NULL THEN 1 ELSE 0 END) AS approval_fy_null_count,
  SUM(CASE WHEN Term IS NULL THEN 1 ELSE 0 END) AS term_null_count,
  SUM(CASE WHEN MIS_Status IS NULL THEN 1 ELSE 0 END) AS mis_status_null_count,
  SUM(CASE WHEN GrAppv IS NULL THEN 1 ELSE 0 END) AS gr_appv_null_count,
  SUM(CASE WHEN SBA_Appv IS NULL THEN 1 ELSE 0 END) AS sba_appv_null_count,
  SUM(CASE WHEN DisbursementDate IS NULL THEN 1 ELSE 0 END) AS disbursement_date_null_count,
  SUM(CASE WHEN DisbursementGross IS NULL THEN 1 ELSE 0 END) AS disbursement_gross_null_count
FROM `raw.loan_applications`;

-- Findings:
-- - LoanNr_ChkDgt is fully populated with no missing values.
-- - Core approval and disbursement fields (ApprovalDate, ApprovalFY, Term,
--   GrAppv, DisbursementDate, DisbursementGross) show full completeness.
-- - MIS_Status contains 669 missing values, indicating gaps in loan status classification.
-- - SBA_Appv contains 766 missing values, indicating incomplete SBA participation data.




