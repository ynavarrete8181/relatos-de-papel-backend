CREATE TABLE IF NOT EXISTS public.purchases (
  id BIGSERIAL PRIMARY KEY,
  buyer_email VARCHAR(255),
  total NUMERIC(10,2) NOT NULL CHECK (total >= 0),
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.purchase_items (
  id BIGSERIAL PRIMARY KEY,
  purchase_id BIGINT NOT NULL,
  book_id BIGINT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
  line_total NUMERIC(10,2) NOT NULL CHECK (line_total >= 0),
  CONSTRAINT fk_purchase_items_purchase
    FOREIGN KEY (purchase_id)
    REFERENCES public.purchases(id)
    ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_purchase_items_purchase_id
  ON public.purchase_items(purchase_id);

CREATE INDEX IF NOT EXISTS idx_purchase_items_book_id
  ON public.purchase_items(book_id);

CREATE INDEX IF NOT EXISTS idx_purchases_created_at
  ON public.purchases(created_at);
