from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta
import pandas as pd
import yfinance as yf
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'email': ['your_email@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'stock_data_etl',
    default_args=default_args,
    description='A DAG to load stock data into Snowflake',
    schedule_interval='@daily',
)

def get_snowflake_connection():
    return snowflake.connector.connect(
        account='',
        user='',
        password='',
        warehouse='',
        database='',
        schema='',
        role=''
    )

def load_company_data():
    conn = get_snowflake_connection()
    sp500 = pd.read_html('https://en.wikipedia.org/wiki/List_of_S%26P_500_companies')[0]
    sp500 = sp500[['Symbol', 'Security', 'GICS Sector', 'GICS Sub-Industry']]
    sp500.columns = ['TICKER', 'COMPANY_NAME', 'SECTOR', 'INDUSTRY']
    
    write_pandas(conn, sp500, 'DIM_COMPANY')
    conn.close()

def load_date_data():
    conn = get_snowflake_connection()
    end_date = datetime.now()
    start_date = end_date - timedelta(days=5*365)
    
    date_range = pd.date_range(start=start_date, end=end_date)
    date_df = pd.DataFrame({
        'DATE_ID': date_range,
        'YEAR': date_range.year,
        'MONTH': date_range.month,
        'DAY': date_range.day,
        'DAY_OF_WEEK': date_range.dayofweek,
        'IS_TRADING_DAY': date_range.dayofweek < 5
    })
    date_df['DATE_ID'] = date_df['DATE_ID'].dt.date    
    write_pandas(conn, date_df, 'DIM_DATE')
    conn.close()

def load_stock_price_data():
    conn = get_snowflake_connection()
    cursor = conn.cursor()
    
    sp500 = pd.read_html('https://en.wikipedia.org/wiki/List_of_S%26P_500_companies')[0]
    tickers = sp500['Symbol'].tolist()
    end_date = datetime.now()
    start_date = end_date - timedelta(days=1)  # Load only the last day's data
    
    for ticker in tickers:
        try:
            stock_data = yf.download(ticker, start=start_date, end=end_date)
            if stock_data.empty:
                print(f"No data available for {ticker}. Skipping...")
                continue
            
            stock_data.reset_index(inplace=True)
            stock_data['ticker'] = ticker
            stock_data = stock_data.rename(columns={
                'Date': 'DATE_ID',
                'Open': 'OPEN_PRICE',
                'High': 'HIGH_PRICE',
                'Low': 'LOW_PRICE',
                'Close': 'CLOSE_PRICE',
                'Volume': 'VOLUME'
            })
            
            stock_data['DATE_ID'] = pd.to_datetime(stock_data['DATE_ID'])
            
            cursor.execute(f"SELECT company_id FROM dim_company WHERE ticker = '{ticker}'")
            result = cursor.fetchone()
            if result is None:
                print(f"No company_id found for ticker {ticker}. Skipping...")
                continue
            company_id = result[0]
            stock_data['COMPANY_ID'] = company_id
            
            stock_data = stock_data[['COMPANY_ID', 'DATE_ID', 'OPEN_PRICE', 'HIGH_PRICE', 'LOW_PRICE', 'CLOSE_PRICE', 'VOLUME']]
            stock_data['DATE_ID'] = stock_data['DATE_ID'].dt.date
            
            write_pandas(conn, stock_data, 'FACT_STOCK_PRICE')
            print(f"Data for {ticker} loaded successfully.")
        
        except Exception as e:
            print(f"Error processing {ticker}: {str(e)}")
            continue
    
    cursor.close()
    conn.close()

load_company_task = PythonOperator(
    task_id='load_company_data',
    python_callable=load_company_data,
    dag=dag,
)

load_date_task = PythonOperator(
    task_id='load_date_data',
    python_callable=load_date_data,
    dag=dag,
)

load_stock_price_task = PythonOperator(
    task_id='load_stock_price_data',
    python_callable=load_stock_price_data,
    dag=dag,
)

load_company_task >> load_date_task >> load_stock_price_task