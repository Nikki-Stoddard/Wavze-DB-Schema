-- View: wavze1.kpi_aggregate_view
-- 
-- Dynamic KPI Aggregate View for Transaction Analytics
-- 
-- This view provides comprehensive KPI aggregations across transactions,
-- automatically aggregating relevant fields based on product categories.
-- The view groups data by product_category, milestone, source, and time dimensions.
--
-- DROP VIEW IF EXISTS wavze1.kpi_aggregate_view;

CREATE OR REPLACE VIEW wavze1.kpi_aggregate_view AS
SELECT 
    -- Dimension Fields
    t.product_category,
    t.product_name,
    t.milestone,
    t.source,
    DATE(t.created_ts) AS transaction_date,
    DATE_TRUNC('month', t.created_ts) AS transaction_month,
    DATE_TRUNC('quarter', t.created_ts) AS transaction_quarter,
    DATE_TRUNC('year', t.created_ts) AS transaction_year,
    
    -- Transaction Count Metrics
    COUNT(DISTINCT t.transaction_id) AS total_transactions,
    COUNT(DISTINCT CASE WHEN t.active = TRUE THEN t.transaction_id END) AS active_transactions,
    COUNT(DISTINCT CASE WHEN t.active = FALSE THEN t.transaction_id END) AS closed_transactions,
    COUNT(DISTINCT CASE WHEN t.duplicate = TRUE THEN t.transaction_id END) AS duplicate_transactions,
    COUNT(DISTINCT CASE WHEN t.time_sensitive = TRUE THEN t.transaction_id END) AS time_sensitive_transactions,
    
    -- Customer Metrics
    COUNT(DISTINCT t.customer_id) AS unique_customers,
    COUNT(DISTINCT CASE WHEN t.active = TRUE THEN t.customer_id END) AS active_customers,
    
    -- Financial Aggregations - Loan/Financing Products
    -- Sum aggregations
    SUM(COALESCE(td.loan_amount, 0)) AS total_loan_amount,
    SUM(COALESCE(td.purchase_price, 0)) AS total_purchase_price,
    SUM(COALESCE(td.down_payment, 0)) AS total_down_payment,
    SUM(COALESCE(td.cash_out, 0)) AS total_cash_out,
    SUM(COALESCE(td.draw_amount, 0)) AS total_draw_amount,
    SUM(COALESCE(td.credit_limit, 0)) AS total_credit_limit,
    SUM(COALESCE(td.cash_advance, 0)) AS total_cash_advance,
    SUM(COALESCE(td.deposit_amount, 0)) AS total_deposit_amount,
    
    -- Average aggregations
    AVG(td.loan_amount) AS avg_loan_amount,
    AVG(td.purchase_price) AS avg_purchase_price,
    AVG(td.down_payment) AS avg_down_payment,
    AVG(td.interest_rate) AS avg_interest_rate,
    AVG(td.apr) AS avg_apr,
    AVG(td.loan_term) AS avg_loan_term,
    AVG(td.credit_limit) AS avg_credit_limit,
    AVG(td.deposit_amount) AS avg_deposit_amount,
    
    -- Min/Max aggregations
    MIN(td.loan_amount) AS min_loan_amount,
    MAX(td.loan_amount) AS max_loan_amount,
    MIN(td.interest_rate) AS min_interest_rate,
    MAX(td.interest_rate) AS max_interest_rate,
    MIN(td.apr) AS min_apr,
    MAX(td.apr) AS max_apr,
    
    -- Count aggregations for non-null fields
    COUNT(td.loan_amount) AS loan_amount_count,
    COUNT(td.purchase_price) AS purchase_price_count,
    COUNT(td.interest_rate) AS interest_rate_count,
    COUNT(td.apr) AS apr_count,
    COUNT(td.deposit_amount) AS deposit_amount_count,
    
    -- Rate Type Distribution
    COUNT(DISTINCT td.rate_type) AS unique_rate_types,
    (MODE() WITHIN GROUP (ORDER BY CASE WHEN td.rate_type IS NOT NULL THEN td.rate_type END)) AS most_common_rate_type,
    
    -- Lien Position Distribution
    AVG(td.lien_position) AS avg_lien_position,
    (MODE() WITHIN GROUP (ORDER BY CASE WHEN td.lien_position IS NOT NULL THEN td.lien_position END))::NUMERIC AS most_common_lien_position,
    
    -- PMI Metrics (for mortgage products)
    COUNT(DISTINCT CASE WHEN td.pmi = TRUE THEN t.transaction_id END) AS transactions_with_pmi,
    COUNT(DISTINCT CASE WHEN td.pmi = FALSE THEN t.transaction_id END) AS transactions_without_pmi,
    
    -- Ownership Type Distribution
    COUNT(DISTINCT td.ownership_type) AS unique_ownership_types,
    (MODE() WITHIN GROUP (ORDER BY CASE WHEN td.ownership_type IS NOT NULL THEN td.ownership_type END)) AS most_common_ownership_type,
    
    -- Co-applicant Metrics
    COUNT(DISTINCT CASE WHEN td.co_appl1 IS NOT NULL THEN t.transaction_id END) AS transactions_with_co_appl1,
    COUNT(DISTINCT CASE WHEN td.co_appl2 IS NOT NULL THEN t.transaction_id END) AS transactions_with_co_appl2,
    
    -- Conversion Metrics (based on milestone progression)
    COUNT(DISTINCT CASE WHEN UPPER(TRIM(t.milestone)) LIKE 'APPLICATION%' THEN t.transaction_id END) AS application_count,
    COUNT(DISTINCT CASE WHEN UPPER(TRIM(t.milestone)) LIKE 'APPROVED%' THEN t.transaction_id END) AS approved_count,
    COUNT(DISTINCT CASE WHEN UPPER(TRIM(t.milestone)) LIKE 'CLOSED%' THEN t.transaction_id END) AS closed_count,
    COUNT(DISTINCT CASE WHEN UPPER(TRIM(t.milestone)) LIKE 'FUNDED%' THEN t.transaction_id END) AS funded_count,
    
    -- Conversion Rates (calculated)
    CASE 
        WHEN COUNT(DISTINCT CASE WHEN UPPER(TRIM(t.milestone)) LIKE 'APPLICATION%' THEN t.transaction_id END) > 0
        THEN ROUND(
            100.0 * COUNT(DISTINCT CASE WHEN UPPER(TRIM(t.milestone)) LIKE 'APPROVED%' THEN t.transaction_id END)::NUMERIC / 
            COUNT(DISTINCT CASE WHEN UPPER(TRIM(t.milestone)) LIKE 'APPLICATION%' THEN t.transaction_id END)::NUMERIC,
            2
        )
        ELSE NULL
    END AS approval_rate_pct,
    
    CASE 
        WHEN COUNT(DISTINCT CASE WHEN UPPER(TRIM(t.milestone)) LIKE 'APPLICATION%' THEN t.transaction_id END) > 0
        THEN ROUND(
            100.0 * COUNT(DISTINCT CASE WHEN UPPER(TRIM(t.milestone)) LIKE 'CLOSED%' THEN t.transaction_id END)::NUMERIC / 
            COUNT(DISTINCT CASE WHEN UPPER(TRIM(t.milestone)) LIKE 'APPLICATION%' THEN t.transaction_id END)::NUMERIC,
            2
        )
        ELSE NULL
    END AS close_rate_pct,
    
    CASE 
        WHEN COUNT(DISTINCT CASE WHEN UPPER(TRIM(t.milestone)) LIKE 'APPLICATION%' THEN t.transaction_id END) > 0
        THEN ROUND(
            100.0 * COUNT(DISTINCT CASE WHEN UPPER(TRIM(t.milestone)) LIKE 'FUNDED%' THEN t.transaction_id END)::NUMERIC / 
            COUNT(DISTINCT CASE WHEN UPPER(TRIM(t.milestone)) LIKE 'APPLICATION%' THEN t.transaction_id END)::NUMERIC,
            2
        )
        ELSE NULL
    END AS funded_rate_pct

FROM wavze1.transaction t
LEFT JOIN wavze1.transaction_detail td ON t.transaction_id = td.transaction_id
WHERE t.product_category IS NOT NULL
GROUP BY 
    t.product_category,
    t.product_name,
    t.milestone,
    t.source,
    DATE(t.created_ts),
    DATE_TRUNC('month', t.created_ts),
    DATE_TRUNC('quarter', t.created_ts),
    DATE_TRUNC('year', t.created_ts);

-- Add comment
COMMENT ON VIEW wavze1.kpi_aggregate_view IS 
'Dynamic KPI Aggregate View providing comprehensive transaction analytics aggregated by product category, milestone, source, and time dimensions. Includes transaction counts, financial aggregations, conversion metrics, and distribution statistics.';

-- Grant permissions (adjust users as needed)
GRANT SELECT ON wavze1.kpi_aggregate_view TO "erik.michaelson@taranginc.com";
GRANT SELECT ON wavze1.kpi_aggregate_view TO "kevin.soderholm@taranginc.com";
GRANT SELECT ON wavze1.kpi_aggregate_view TO "jagadeesh.pasupulati@taranginc.com";
GRANT SELECT ON wavze1.kpi_aggregate_view TO "wavze1@wavze1db2";

