CREATE OR REPLACE MATERIALIZED VIEW mv_stock_performance AS
SELECT 
  c.ticker,
  c.company_name,
  f.date_id,
  f.close_price,
  LAG(f.close_price, 30) OVER (PARTITION BY c.company_id ORDER BY f.date_id) AS price_30_days_ago
FROM fact_stock_price f
JOIN dim_company c ON f.company_id = c.company_id
WHERE f.date_id >= DATEADD(day, -90, CURRENT_DATE());