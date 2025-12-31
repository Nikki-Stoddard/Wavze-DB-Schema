-- View: wavze1.kpi_ytd_by_user

-- DROP MATERIALIZED VIEW IF EXISTS wavze1.kpi_ytd_by_user;

CREATE MATERIALIZED VIEW IF NOT EXISTS wavze1.kpi_ytd_by_user
TABLESPACE pg_default
AS
 WITH leadgen AS (
         SELECT transaction_milestone_kpi.transaction_id,
            transaction_milestone_kpi.customer_id,
            transaction_milestone_kpi.generate_dt,
            transaction_milestone_kpi.appl_flag,
            transaction_milestone_kpi.outcome_dt,
            transaction_milestone_kpi.win_flag
           FROM wavze1.transaction_milestone_kpi
          WHERE transaction_milestone_kpi.generate_dt >= date_trunc('year'::text, CURRENT_DATE::timestamp with time zone)
        ), outcome AS (
         SELECT transaction_milestone_kpi.transaction_id,
            transaction_milestone_kpi.customer_id,
            transaction_milestone_kpi.generate_dt,
            transaction_milestone_kpi.appl_flag,
            transaction_milestone_kpi.outcome_dt,
            transaction_milestone_kpi.win_flag
           FROM wavze1.transaction_milestone_kpi
          WHERE transaction_milestone_kpi.outcome_dt >= date_trunc('year'::text, CURRENT_DATE::timestamp with time zone)
        )
 SELECT t.user_id,
    u.preferred_name,
    u.last_name,
    count(DISTINCT lg.customer_id) AS new_cust,
    sum(lg.appl_flag) AS appl_count,
    avg(lg.appl_flag) AS appl_rate,
    sum(o.win_flag) AS acct_opens,
    avg(o.win_flag) AS win_rate
   FROM leadgen lg
     JOIN wavze1.transaction t ON t.transaction_id = lg.transaction_id
     LEFT JOIN outcome o ON o.transaction_id = lg.transaction_id
     JOIN wavze1.wavze_user u ON u.user_id = t.user_id
  GROUP BY t.user_id, u.preferred_name, u.last_name
WITH NO DATA;

ALTER TABLE IF EXISTS wavze1.kpi_ytd_by_user
    OWNER TO "nikki.stoddard@taranginc.com";
    