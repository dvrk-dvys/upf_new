DROP TABLE IF EXISTS orders;
CREATE TABLE orders
 (city_code VARCHAR(255) NOT NULL,
  ORDER_ID INT NOT NULL,
  PRIMARY KEY (ORDER_ID));

LOAD DATA LOCAL INFILE '/Users/jordanharris/Downloads/orders.csv'
  INTO TABLE orders
  FIELDS TERMINATED BY ','
  LINES TERMINATED BY '\n'
  IGNORE 1 ROWS (city_code, order_id);