WITH price_volume AS (
  SELECT 
    company_id,
    CORR(close_price, volume) AS price_volume_correlation
  FROM fact_stock_price
  WHERE date_id >= DATEADD(year, -1, CURRENT_DATE())
  GROUP BY company_id
)
SELECT 
  c.ticker,
  c.company_name,
  pv.price_volume_correlation
FROM price_volume pv
JOIN dim_company c ON pv.company_id = c.company_id
ORDER BY pv.price_volume_correlation DESC
LIMIT 10;