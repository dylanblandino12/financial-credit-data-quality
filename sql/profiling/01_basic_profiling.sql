-- =====================================
-- File: 01_basic_profiling.sql
-- Purpose: Initial data profiling to assess data completeness,
--          value ranges, and potential quality issues on raw data
-- Dataset: Credit Risk Dataset
-- Layer: RAW
-- Tool: Google BigQuery
-- =====================================

SELECT COUNT(*) AS total_rows
FROM `raw.lending_club_loans_sample`;

-- Findings:
-- - Each row represents a loan record.
-- - Potential candidate keys identified: id (loan-level), member_id (customer-level).
-- - Uniqueness not validated at this stage.


SELECT
  column_name,
  data_type,
  is_nullable
FROM
  `raw.INFORMATION_SCHEMA.COLUMNS`
WHERE
  table_name = 'lending_club_loans_sample'
ORDER BY
  ordinal_position;

-- Findings:
-- - Schema reviewed using INFORMATION_SCHEMA for reproducibility.
-- - Dataset contains a mix of numeric, categorical, and boolean fields.
-- - Several fields are nullable and will require completeness checks in later steps.
