CREATE OR REPLACE TEMPORARY TABLE temp_daily_returns AS
WITH daily_returns AS (
  SELECT 
    c.sector,
    f.date_id,
    AVG((f.close_price - LAG(f.close_price) OVER (PARTITION BY f.company_id ORDER BY f.date_id)) 
        / LAG(f.close_price) OVER (PARTITION BY f.company_id ORDER BY f.date_id)) AS avg_return
  FROM fact_stock_price f
  JOIN dim_company c ON f.company_id = c.company_id
  WHERE f.date_id >= DATEADD(month, -3, CURRENT_DATE())
  GROUP BY c.sector, f.date_id
);

SELECT 
  sector,
  STDDEV(avg_return) * SQRT(252) AS annualized_volatility
FROM temp_daily_returns
GROUP BY sector
ORDER BY annualized_volatility DESC;