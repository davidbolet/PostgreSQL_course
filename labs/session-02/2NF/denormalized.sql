CREATE TABLE order_items_denorm (
  order_id    BIGINT,
  product_id  BIGINT,
  qty         INT,
  product_name TEXT,
  unit_price   NUMERIC(10,2),
  PRIMARY KEY (order_id, product_id)
);

INSERT INTO order_items_denorm VALUES
(1001,10,2,'Widget',19.99),
(1002,10,1,'Widget',19.99),
(1003,11,3,'Gadget', 9.50);