-- Tabla de dimensión para las compañías
CREATE TABLE IF NOT EXISTS dim_company (
    company_id INTEGER AUTOINCREMENT,
    ticker VARCHAR(10) NOT NULL,
    company_name VARCHAR(255),
    sector VARCHAR(100),
    industry VARCHAR(100),
    PRIMARY KEY (company_id),
    UNIQUE (ticker)
);