-- KPI Aggregate View Usage Examples
-- 
-- This file contains example queries demonstrating how to use the 
-- kpi_aggregate_view and kpi_summary_view for various analytical purposes
--

-- ============================================================================
-- EXAMPLE 1: Monthly KPI Summary by Product Category
-- ============================================================================
-- Get high-level KPIs aggregated by month and product category
SELECT 
    product_category,
    transaction_month,
    total_transactions,
    active_transactions,
    closed_transactions,
    total_loan_amount,
    weighted_avg_loan_amount,
    overall_approval_rate_pct,
    overall_close_rate_pct,
    overall_funded_rate_pct
FROM wavzedemo.kpi_summary_view
WHERE transaction_month >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '12 months')
ORDER BY product_category, transaction_month DESC;

-- ============================================================================
-- EXAMPLE 2: Detailed KPI by Milestone for a Specific Product Category
-- ============================================================================
-- Get detailed KPIs for Mortgage Purchase products, broken down by milestone
SELECT 
    product_category,
    milestone,
    transaction_month,
    total_transactions,
    avg_loan_amount,
    avg_interest_rate,
    avg_purchase_price,
    avg_down_payment,
    approval_rate_pct,
    close_rate_pct
FROM wavzedemo.kpi_aggregate_view
WHERE product_category = 'Mortgage Purchase'
    AND transaction_month >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '6 months')
ORDER BY milestone, transaction_month DESC;

-- ============================================================================
-- EXAMPLE 3: Source Performance Analysis
-- ============================================================================
-- Compare performance metrics across different transaction sources
SELECT 
    source,
    product_category,
    COUNT(*) AS record_count,
    SUM(total_transactions) AS total_transactions,
    SUM(active_transactions) AS active_transactions,
    SUM(total_loan_amount) AS total_loan_amount,
    AVG(avg_loan_amount) AS avg_loan_amount,
    AVG(approval_rate_pct) AS avg_approval_rate,
    AVG(close_rate_pct) AS avg_close_rate
FROM wavzedemo.kpi_aggregate_view
WHERE source IS NOT NULL
    AND transaction_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY source, product_category
ORDER BY total_transactions DESC;

-- ============================================================================
-- EXAMPLE 4: Product Category Comparison (Year-to-Date)
-- ============================================================================
-- Compare all product categories for the current year
SELECT 
    product_category,
    SUM(total_transactions) AS ytd_transactions,
    SUM(active_transactions) AS ytd_active,
    SUM(closed_transactions) AS ytd_closed,
    SUM(total_loan_amount) AS ytd_total_loan_amount,
    SUM(total_deposit_amount) AS ytd_total_deposits,
    AVG(weighted_avg_loan_amount) AS ytd_avg_loan_amount,
    AVG(overall_approval_rate_pct) AS ytd_avg_approval_rate,
    AVG(overall_close_rate_pct) AS ytd_avg_close_rate,
    AVG(overall_funded_rate_pct) AS ytd_avg_funded_rate
FROM wavzedemo.kpi_summary_view
WHERE transaction_year = DATE_TRUNC('year', CURRENT_DATE)
GROUP BY product_category
ORDER BY ytd_transactions DESC;

-- ============================================================================
-- EXAMPLE 5: Daily Transaction Trends
-- ============================================================================
-- Track daily transaction volumes and amounts for a specific product
SELECT 
    transaction_date,
    product_category,
    milestone,
    total_transactions,
    active_transactions,
    total_loan_amount,
    avg_loan_amount,
    avg_interest_rate
FROM wavzedemo.kpi_aggregate_view
WHERE product_category = 'Mortgage Purchase'
    AND transaction_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY transaction_date DESC, milestone;

-- ============================================================================
-- EXAMPLE 6: Conversion Funnel Analysis
-- ============================================================================
-- Analyze the conversion funnel from application to funding
SELECT 
    product_category,
    transaction_month,
    SUM(application_count) AS applications,
    SUM(approved_count) AS approved,
    SUM(closed_count) AS closed,
    SUM(funded_count) AS funded,
    ROUND(100.0 * SUM(approved_count)::NUMERIC / NULLIF(SUM(application_count), 0), 2) AS app_to_approved_pct,
    ROUND(100.0 * SUM(closed_count)::NUMERIC / NULLIF(SUM(approved_count), 0), 2) AS approved_to_closed_pct,
    ROUND(100.0 * SUM(funded_count)::NUMERIC / NULLIF(SUM(closed_count), 0), 2) AS closed_to_funded_pct
FROM wavzedemo.kpi_aggregate_view
WHERE transaction_month >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '12 months')
GROUP BY product_category, transaction_month
ORDER BY product_category, transaction_month DESC;

-- ============================================================================
-- EXAMPLE 7: Interest Rate Analysis by Product
-- ============================================================================
-- Analyze interest rates and APR across different products
SELECT 
    product_category,
    most_common_rate_type,
    AVG(avg_interest_rate) AS avg_interest_rate,
    AVG(avg_apr) AS avg_apr,
    MIN(min_interest_rate) AS min_interest_rate,
    MAX(max_interest_rate) AS max_interest_rate,
    COUNT(*) AS sample_size
FROM wavzedemo.kpi_aggregate_view
WHERE avg_interest_rate IS NOT NULL
    AND transaction_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY product_category, most_common_rate_type
ORDER BY product_category, avg_interest_rate;

-- ============================================================================
-- EXAMPLE 8: Duplicate Transaction Analysis
-- ============================================================================
-- Identify product categories and sources with high duplicate rates
SELECT 
    product_category,
    source,
    SUM(total_transactions) AS total_transactions,
    SUM(duplicate_transactions) AS duplicate_transactions,
    ROUND(
        100.0 * SUM(duplicate_transactions)::NUMERIC / 
        NULLIF(SUM(total_transactions), 0), 
        2
    ) AS duplicate_rate_pct
FROM wavzedemo.kpi_aggregate_view
WHERE transaction_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY product_category, source
HAVING SUM(duplicate_transactions) > 0
ORDER BY duplicate_rate_pct DESC;

-- ============================================================================
-- EXAMPLE 9: Time-Sensitive Transaction Metrics
-- ============================================================================
-- Analyze time-sensitive transactions and their outcomes
SELECT 
    product_category,
    milestone,
    SUM(total_transactions) AS total_transactions,
    SUM(time_sensitive_transactions) AS time_sensitive_count,
    ROUND(
        100.0 * SUM(time_sensitive_transactions)::NUMERIC / 
        NULLIF(SUM(total_transactions), 0), 
        2
    ) AS time_sensitive_pct,
    AVG(close_rate_pct) AS avg_close_rate
FROM wavzedemo.kpi_aggregate_view
WHERE transaction_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY product_category, milestone
ORDER BY product_category, milestone;

-- ============================================================================
-- EXAMPLE 10: Product-Specific KPIs (Example: Deposit Products)
-- ============================================================================
-- Focus on deposit-related products (Checking, Savings, CD, Money Market)
SELECT 
    product_category,
    transaction_month,
    total_transactions,
    total_deposit_amount,
    avg_deposit_amount,
    most_common_ownership_type,
    most_common_rate_type,
    avg_interest_rate
FROM wavzedemo.kpi_aggregate_view
WHERE product_category IN ('Checking', 'Savings', 'Certificate of Deposit (CD)', 'Money Market')
    AND transaction_month >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '12 months')
ORDER BY product_category, transaction_month DESC;

-- ============================================================================
-- EXAMPLE 11: Loan Products KPI Comparison
-- ============================================================================
-- Compare loan products by key metrics
SELECT 
    product_category,
    SUM(total_transactions) AS total_transactions,
    SUM(total_loan_amount) AS total_loan_amount,
    AVG(avg_loan_amount) AS avg_loan_amount,
    AVG(avg_interest_rate) AS avg_interest_rate,
    AVG(avg_loan_term) AS avg_loan_term,
    AVG(approval_rate_pct) AS avg_approval_rate,
    AVG(funded_rate_pct) AS avg_funded_rate
FROM wavzedemo.kpi_aggregate_view
WHERE product_category IN (
    'Mortgage Purchase', 
    'Mortgage Refinance', 
    'Home Equity Loan',
    'Personal Loan',
    'Auto Purchase',
    'Student Loan'
)
    AND transaction_month >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '12 months')
GROUP BY product_category
ORDER BY total_loan_amount DESC;

-- ============================================================================
-- EXAMPLE 12: Quarter-over-Quarter Growth Analysis
-- ============================================================================
-- Compare current quarter to previous quarter performance
WITH quarterly_kpis AS (
    SELECT 
        product_category,
        transaction_quarter,
        SUM(total_transactions) AS q_transactions,
        SUM(total_loan_amount) AS q_loan_amount,
        AVG(overall_approval_rate_pct) AS q_approval_rate
    FROM wavzedemo.kpi_summary_view
    WHERE transaction_quarter >= DATE_TRUNC('quarter', CURRENT_DATE - INTERVAL '6 months')
    GROUP BY product_category, transaction_quarter
)
SELECT 
    curr.product_category,
    curr.transaction_quarter AS current_quarter,
    prev.transaction_quarter AS previous_quarter,
    curr.q_transactions AS curr_transactions,
    prev.q_transactions AS prev_transactions,
    ROUND(
        100.0 * (curr.q_transactions - prev.q_transactions)::NUMERIC / 
        NULLIF(prev.q_transactions, 0), 
        2
    ) AS transaction_growth_pct,
    curr.q_loan_amount AS curr_loan_amount,
    prev.q_loan_amount AS prev_loan_amount,
    ROUND(
        100.0 * (curr.q_loan_amount - prev.q_loan_amount)::NUMERIC / 
        NULLIF(prev.q_loan_amount, 0), 
        2
    ) AS loan_amount_growth_pct
FROM quarterly_kpis curr
LEFT JOIN quarterly_kpis prev 
    ON curr.product_category = prev.product_category
    AND prev.transaction_quarter = curr.transaction_quarter - INTERVAL '3 months'
WHERE curr.transaction_quarter = DATE_TRUNC('quarter', CURRENT_DATE)
ORDER BY transaction_growth_pct DESC NULLS LAST;





