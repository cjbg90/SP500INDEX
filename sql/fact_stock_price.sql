-- Tabla de hechos para los precios diarios de las acciones
CREATE TABLE IF NOT EXISTS fact_stock_price (
    stock_price_id INTEGER AUTOINCREMENT,
    company_id INTEGER NOT NULL,
    date_id DATE NOT NULL,
    open_price DECIMAL(10,2),
    high_price DECIMAL(10,2),
    low_price DECIMAL(10,2),
    close_price DECIMAL(10,2),
    volume INTEGER,
    PRIMARY KEY (stock_price_id),
    FOREIGN KEY (company_id) REFERENCES dim_company(company_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);