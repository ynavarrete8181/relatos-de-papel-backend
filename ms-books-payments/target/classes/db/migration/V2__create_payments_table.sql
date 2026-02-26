CREATE TABLE IF NOT EXISTS payments (
  id               BIGSERIAL PRIMARY KEY,
  book_id          BIGINT NOT NULL,
  book_isbn        VARCHAR(20) NOT NULL,
  book_title       VARCHAR(255) NOT NULL,
  unit_price       NUMERIC(10,2) NOT NULL,
  quantity         INT NOT NULL CHECK (quantity > 0),
  total            NUMERIC(10,2) NOT NULL,
  buyer_email      VARCHAR(255) NOT NULL,
  status           VARCHAR(30) NOT NULL DEFAULT 'CREATED',
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payments_buyer_email ON payments(buyer_email);
CREATE INDEX IF NOT EXISTS idx_payments_book_isbn ON payments(book_isbn);
