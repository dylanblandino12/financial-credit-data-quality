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

--Uniquess
SELECT
  COUNT(DISTINCT LoanNr_ChkDgt) as unique_loans
FROM
  `raw.loan_applications`;

-- Findings:
-- - The dataset contains 299,990 loan application records.
-- - Each row represents a single loan application.

--Check null values (completeness)

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

-- Value Ranges & Basic Validity 

SELECT
  SUM(CASE WHEN Term < 0 THEN 1 ELSE 0 END) AS invalid_term_count,
  SUM(CASE WHEN GrAppv < 0 THEN 1 ELSE 0 END) AS invalid_grappv_count,
  SUM(CASE WHEN SBA_Appv < 0 THEN 1 ELSE 0 END) AS invalid_sba_negative_count,
  SUM(CASE WHEN SBA_Appv > GrAppv THEN 1 ELSE 0 END) AS invalid_sba_exceeds_grappv_count,
  SUM(CASE WHEN DisbursementGross < 0 THEN 1 ELSE 0 END) AS invalid_disbursement_amount_count,
  SUM(CASE WHEN ApprovalFY < 1900 OR ApprovalFY > 2026 THEN 1 ELSE 0 END) AS invalid_approvalfy_count,
  SUM(CASE WHEN ApprovalDate > DATE '2026-01-10' THEN 1 ELSE 0 END) AS invalid_future_approval_date_count,
  SUM(CASE WHEN DisbursementDate > DATE '2026-01-10' THEN 1 ELSE 0 END) AS invalid_future_disbursement_date_count,
  SUM(CASE WHEN DisbursementGross > 0 AND DisbursementDate IS NULL THEN 1 ELSE 0 END) AS missing_disbursement_date_count
FROM `raw.loan_applications`;

-- Findings:
-- - No invalid values were found for loan term, approved amounts, SBA amounts, or disbursement amounts.
-- - Two records contain approval dates in the future, and one record containsa future disbursement date, indicating minor date validity issues.
-- - 711 records have missing disbursement dates despite having a positive disbursement amount, representing a significant data quality risk in disbursement tracking.


-- =====================================
-- Consistency Checks
-- =====================================

SELECT
  -- Disbursement should not exceed approved amount
  SUM(CASE WHEN DisbursementGross > GrAppv THEN 1 ELSE 0 END) AS disbursement_exceeds_approved_count,
  -- SBA approved amount should not exceed total approved amount
  SUM(CASE WHEN SBA_Appv > GrAppv THEN 1 ELSE 0 END) AS sba_exceeds_approved_count,
-- Charged-off date should only exist for charged-off loans
  SUM(CASE WHEN ChgOffDate IS NOT NULL AND MIS_Status <> 'CHGOFF'THEN 1 ELSE 0 END) AS chargeoff_date_status_mismatch_count,
-- Disbursement date should exist when disbursement amount is positive
  SUM(CASE WHEN DisbursementGross > 0 AND DisbursementDate IS NULL THEN 1 ELSE 0 END) AS disbursement_missing_date_count
FROM `raw.loan_applications`;


-- Findings:
-- - 51,914 records have disbursement amounts exceeding the approved amount, indicating a major consistency issue between approval and disbursement data.
-- - No cases were found where SBA approved amounts exceed total approved amounts.
-- - 1,624 records contain a charge-off date while the loan status is not marked as charged-off, indicating status-to-date inconsistencies.
-- - 711 records have a positive disbursement amount but a missing disbursement date, confirming a recurring disbursement tracking issue.


-- =====================================
-- Data Quality Summary
-- =====================================

SELECT
  COUNT(*) AS total_records,
  -- ==============================
  -- Completeness Issues
  -- ==============================
  (
    SUM(CASE WHEN MIS_Status IS NULL THEN 1 ELSE 0 END)
  + SUM(CASE WHEN SBA_Appv IS NULL THEN 1 ELSE 0 END)
  + SUM(CASE WHEN DisbursementGross > 0 AND DisbursementDate IS NULL THEN 1 ELSE 0 END)
  ) AS completeness_issues,

  -- ==============================
  -- Validity Issues
  -- ==============================
  (
    SUM(CASE WHEN Term < 0 THEN 1 ELSE 0 END)
  + SUM(CASE WHEN GrAppv < 0 THEN 1 ELSE 0 END)
  + SUM(CASE WHEN SBA_Appv < 0 THEN 1 ELSE 0 END)
  + SUM(CASE WHEN DisbursementGross < 0 THEN 1 ELSE 0 END)
  + SUM(CASE WHEN ApprovalFY < 1900 OR ApprovalFY > 2026 THEN 1 ELSE 0 END)
  + SUM(CASE WHEN ApprovalDate > DATE '2026-01-10' THEN 1 ELSE 0 END)
  + SUM(CASE WHEN DisbursementDate > DATE '2026-01-10' THEN 1 ELSE 0 END)
  ) AS validity_issues,

  -- ==============================
  -- Consistency Issues
  -- ==============================
  (
    SUM(CASE WHEN DisbursementGross > GrAppv THEN 1 ELSE 0 END)
  + SUM(CASE WHEN ChgOffDate IS NOT NULL AND MIS_Status <> 'CHGOFF' THEN 1 ELSE 0 END)
  ) AS consistency_issues

FROM `raw.loan_applications`;

-- Findings:
-- - The dataset contains 299,990 total records.
-- - Completeness issues were identified in 1,380 records, primarily related to missing loan status and SBA approval information.
-- - Validity issues are minimal (3 records), indicating strong numeric and date integrity.
-- - Consistency issues affect 53,538 records, driven mainly by mismatches between approved and disbursed amounts and charge-off status inconsistencies.

