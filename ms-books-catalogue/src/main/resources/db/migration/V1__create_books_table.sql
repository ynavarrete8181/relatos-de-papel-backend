CREATE TABLE IF NOT EXISTS books (
  id           VARCHAR(50) PRIMARY KEY,
  title        VARCHAR(255) NOT NULL,
  author       VARCHAR(255) NOT NULL,
  price        NUMERIC(10,2) NOT NULL,
  cover        TEXT,
  description  TEXT
);
