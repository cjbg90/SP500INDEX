# Configuración de Snowflake

Para configurar Snowflake para nuestra solución de análisis del S&P 500, siga estos pasos:

1. Asegúrese de tener una cuenta de Snowflake activa.

2. Navegue al directorio de sql de Snowflake:
cd sql/model
Copy
3. Revise y, si es necesario, modifique los archivos db_schema.sql, dim_company.sql, dim_date.sql y fact_stock_price.sql para ajustar cualquier configuración específica de su entorno.

4. Conéctese a su cuenta de Snowflake utilizando el cliente SQL de su elección.

5. Ejecute los scripts db_schema.sql, dim_company.sql, dim_date.sql y fact_stock_price.sql en su cliente SQL:
```sql
USE ROLE ACCOUNTADMIN;
\i db_schema.sql
USE ROLE ACCOUNTADMIN;
\i dim_company.sql
USE ROLE ACCOUNTADMIN;
\i dim_date.sql
USE ROLE ACCOUNTADMIN;
\i fact_stock_price.sql


Este script creará los warehouses, bases de datos, y esquemas necesarios para nuestra solución.
Verifique que todas las estructuras se hayan creado correctamente ejecutando consultas de prueba en Snowflake.
Tome nota de los nombres de los recursos creados, ya que los necesitará para configurar Airflow.

Recuerde que el uso de Snowflake puede generar costos. Asegúrese de entender estos costos y de monitorear su uso.