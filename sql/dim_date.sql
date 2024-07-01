-- Tabla de dimensión para las fechas
CREATE TABLE IF NOT EXISTS dim_date (
    date_id DATE NOT NULL,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    day_of_week INTEGER,
    is_trading_day BOOLEAN,
    PRIMARY KEY (date_id)
);