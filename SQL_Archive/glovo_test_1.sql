DROP TABLE IF EXISTS customer_courier_chat_messages;
CREATE TABLE customer_courier_chat_messages
 (SENDER_APP_TYPE VARCHAR(255) NOT NULL,
 convoid int NOT NULL AUTO_INCREMENT,
 CUSTOMER_ID INT NOT NULL,
 FROM_ID INT NOT NULL,
 TO_ID INT NOT NULL,
 CHAT_STARTED_BY_MESSAGE VARCHAR(255) NOT NULL,
 ORDER_ID INT NOT NULL,
 ORDER_STAGE VARCHAR(255) NOT NULL,
 COURIER_ID INT NOT NULL,
 MESSAGE_SENT_TIME DATETIME,
 PRIMARY KEY (convoid));

LOAD DATA LOCAL INFILE '/Users/jordanharris/Downloads/customer_courier_chat_messages 2.csv'
  INTO TABLE customer_courier_chat_messages
  FIELDS TERMINATED BY ','
  LINES TERMINATED BY '\n'
  IGNORE 1 ROWS (sender_app_type, customer_id, from_id, to_id, chat_started_by_message, order_id, order_stage, courier_id, message_sent_time);