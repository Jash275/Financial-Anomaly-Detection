-- ============================================================
-- Financial Transaction Anomaly Detection & Audit Reporting
-- SQL Setup & Audit Queries
-- Dataset: 217,441 financial transactions (Kaggle)
-- ============================================================

-- 1. DATABASE & TABLE SETUP
CREATE DATABASE financial_audit;
USE financial_audit;

CREATE TABLE transactions (
  txn_timestamp VARCHAR(30),
  transaction_id VARCHAR(20),
  account_id VARCHAR(20),
  amount VARCHAR(20),
  merchant VARCHAR(50),
  transaction_type VARCHAR(20),
  location VARCHAR(50)
);

-- 2. DATA IMPORT
-- CSV file placed in MySQL's secure upload directory before running this
LOAD DATA INFILE 'financial_anomaly_data.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(txn_timestamp, transaction_id, account_id, amount, merchant, transaction_type, location);

-- Confirm row count
SELECT COUNT(*) FROM transactions;
-- Expected: 217441

-- ============================================================
-- 3. AUDIT QUERIES
-- ============================================================

-- Query 1: Top 20 highest-value transactions
-- Purpose: High-value transactions carry the highest inherent audit risk
SELECT * FROM transactions
ORDER BY CAST(amount AS DECIMAL(12,2)) DESC
LIMIT 20;

-- Query 2: Per-account transaction volume & total spend
-- Purpose: Identify accounts with unusual concentration of activity/value
SELECT account_id,
       COUNT(*) AS total_transactions,
       SUM(CAST(amount AS DECIMAL(12,2))) AS total_amount
FROM transactions
GROUP BY account_id
ORDER BY total_amount DESC;

-- Query 3: Duplicate payment detection
-- Purpose: Same account + same amount occurring multiple times is a classic
-- duplicate-payment / fraud red flag
SELECT account_id, amount, COUNT(*) AS occurrence_count
FROM transactions
GROUP BY account_id, amount
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;

-- Query 4: Location-wise withdrawal pattern
-- Purpose: Identify geographic concentration of withdrawal activity
SELECT location,
       transaction_type,
       COUNT(*) AS count,
       SUM(CAST(amount AS DECIMAL(12,2))) AS total
FROM transactions
WHERE transaction_type = 'Withdrawal'
GROUP BY location, transaction_type
ORDER BY total DESC;
