# Proyecto de Análisis de Datos del S&P 500

Este proyecto implementa un pipeline de datos para analizar el rendimiento histórico de las acciones del S&P 500, utilizando AWS, Airflow y Snowflake.

## Arquitectura

[Incluir un diagrama de la arquitectura aquí]

- **AWS VPC**: Proporciona un entorno de red aislado.
- **EC2**: Ejecuta Apache Airflow para la orquestación de tareas.
- **RDS**: Almacena los metadatos de Airflow.
- **S3**: Almacena datos crudos y procesados.
- **Snowflake**: Realiza el almacenamiento y procesamiento de datos a gran escala.

## Requisitos previos

- Cuenta de AWS
- Cuenta de Snowflake
- Python 3.8+
- Apache Airflow 2.0+

## Configuración

1. Clonar este repositorio:
git clone https://github.com/tu-usuario/sp500-analysis.git

2. Descomprimir snowflake_secrets.exe con la contraseña proporcionada por César Bravo mediante correo electrónico.

3. Copiar los valores de los secretos, ir a notebooks, full_load.ipynb y en la función get_snowflake_connection() y pegar los valores.

4. Copiar los valores de los secretos, ir a dags, stock_data_etl.py y en la función get_snowflake_connection() y pegar los valores.

5. Configurar Snowflake:
- Seguir las instrucciones en `docs/snowflake-setup.md` para configurar warehouses, databases y schemas.


6. Configurar la infraestructura AWS:
- Seguir las instrucciones en `docs/aws-setup.md` para configurar VPC, EC2, RDS y S3.


7. Configurar Airflow:
- Seguir las instrucciones en `docs/airflow-setup.md` para instalar y configurar Airflow en EC2.

## Ejecución

1. Iniciar Airflow:
airflow webserver -D
airflow scheduler -D

2. Acceder a la UI de Airflow en `http://<EC2-Public-IP>:8080`

3. Activar el DAG `stock_data_etl.py`

4. Acceder a dashboards, abrir power bi y ejecutar el archivo pbix, en conexión colocar los valores de snowflake secrets para acceder a los datos del datawarehouse

5. Revisar e interpretar las visualizaciones.

## Estructura del proyecto
SP500INDEX/
├── dags/
│   └── stock_data_etl.py
├── dashboards/
│   └── S&P500.pbix
├── docs/
│   ├── aws-setup.md
│   ├── snowflake-setup.md
│   └── airflow-setup.md
├── notebooks/
│   └── full_load.ipynb
├── sql/
│   ├── analytics/
│   │   ├── daily_returns.sql
│   │   ├── price_volume.sql
│   │   └── stock_performance.sql 
│   ├── model/
│   │   ├── db_schema.sql
│   │   ├── dim_company.sql
│   │   ├── dim_date.sql
│   │   └── fact_stock_price.sql
│   ├── optimized querys/
│   │   ├── analytics/
│   │   │   ├── mv_stock_performance.sql
│   │   │   └── temp_daily_returns_performance.sql
│   │   └── model
│   │       └── fact_stock_price_cluster.sql
├── terraform/
│   └── aws.tf
├── README.md
├── requirements.txt
└──snowflake_secrets.exe

## Decisiones técnicas

- **AWS**: Elegido por su escalabilidad y amplia gama de servicios.
- **Airflow**: Utilizado para la orquestación de tareas debido a su flexibilidad y robustez.
- **Snowflake**: Seleccionado como data warehouse por su capacidad de manejar grandes volúmenes de datos y su modelo de precios basado en el uso.
