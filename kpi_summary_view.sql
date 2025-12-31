-- View: wavze1.kpi_summary_view
-- 
-- High-Level KPI Summary View
-- 
-- Provides aggregated KPIs at a summary level (by product category, by month, etc.)
-- Useful for dashboard and reporting purposes
--
-- DROP VIEW IF EXISTS wavze1.kpi_summary_view;

CREATE OR REPLACE VIEW wavze1.kpi_summary_view AS
SELECT 
    -- Dimension Fields (summary level)
    product_category,
    transaction_month,
    transaction_year,
    
    -- Overall Transaction Metrics
    SUM(total_transactions) AS total_transactions,
    SUM(active_transactions) AS active_transactions,
    SUM(closed_transactions) AS closed_transactions,
    SUM(duplicate_transactions) AS duplicate_transactions,
    
    -- Overall Customer Metrics
    SUM(unique_customers) AS total_unique_customers,
    SUM(active_customers) AS total_active_customers,
    
    -- Overall Financial Metrics
    SUM(total_loan_amount) AS total_loan_amount,
    SUM(total_purchase_price) AS total_purchase_price,
    SUM(total_deposit_amount) AS total_deposit_amount,
    SUM(total_credit_limit) AS total_credit_limit,
    
    -- Weighted Average Financial Metrics
    CASE 
        WHEN SUM(loan_amount_count) > 0 
        THEN SUM(total_loan_amount) / SUM(loan_amount_count)
        ELSE NULL
    END AS weighted_avg_loan_amount,
    
    CASE 
        WHEN SUM(interest_rate_count) > 0 
        THEN SUM(avg_interest_rate * interest_rate_count) / SUM(interest_rate_count)
        ELSE NULL
    END AS weighted_avg_interest_rate,
    
    -- Conversion Metrics (aggregated)
    SUM(application_count) AS total_applications,
    SUM(approved_count) AS total_approved,
    SUM(closed_count) AS total_closed,
    SUM(funded_count) AS total_funded,
    
    -- Overall Conversion Rates
    CASE 
        WHEN SUM(application_count) > 0
        THEN ROUND(
            100.0 * SUM(approved_count)::NUMERIC / SUM(application_count)::NUMERIC,
            2
        )
        ELSE NULL
    END AS overall_approval_rate_pct,
    
    CASE 
        WHEN SUM(application_count) > 0
        THEN ROUND(
            100.0 * SUM(closed_count)::NUMERIC / SUM(application_count)::NUMERIC,
            2
        )
        ELSE NULL
    END AS overall_close_rate_pct,
    
    CASE 
        WHEN SUM(application_count) > 0
        THEN ROUND(
            100.0 * SUM(funded_count)::NUMERIC / SUM(application_count)::NUMERIC,
            2
        )
        ELSE NULL
    END AS overall_funded_rate_pct,
    
    -- Active vs Closed Ratio
    CASE 
        WHEN SUM(closed_transactions) > 0
        THEN ROUND(
            SUM(active_transactions)::NUMERIC / SUM(closed_transactions)::NUMERIC,
            2
        )
        ELSE NULL
    END AS active_to_closed_ratio

FROM wavze1.kpi_aggregate_view
GROUP BY 
    product_category,
    transaction_month,
    transaction_year;

-- Add comment
COMMENT ON VIEW wavze1.kpi_summary_view IS 
'High-level KPI summary view aggregating metrics by product category and time periods. Provides overall transaction, customer, financial, and conversion metrics for dashboard reporting.';

-- Grant permissions
GRANT SELECT ON wavze1.kpi_summary_view TO "erik.michaelson@taranginc.com";
GRANT SELECT ON wavze1.kpi_summary_view TO "kevin.soderholm@taranginc.com";
GRANT SELECT ON wavze1.kpi_summary_view TO "jagadeesh.pasupulati@taranginc.com";
GRANT SELECT ON wavze1.kpi_summary_view TO "wavze1@wavze1db2";





