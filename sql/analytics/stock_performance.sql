WITH stock_performance AS (
  SELECT 
    c.ticker,
    c.company_name,
    f.date_id,
    f.close_price,
    LAG(f.close_price, 30) OVER (PARTITION BY c.company_id ORDER BY f.date_id) AS price_30_days_ago
  FROM fact_stock_price f
  JOIN dim_company c ON f.company_id = c.company_id
  WHERE f.date_id >= DATEADD(day, -30, CURRENT_DATE())
)
SELECT 
  ticker,
  company_name,
  (close_price - price_30_days_ago) / price_30_days_ago * 100 AS percent_change
FROM stock_performance
WHERE date_id = (SELECT MAX(date_id) FROM fact_stock_price)
ORDER BY percent_change DESC
LIMIT 10;