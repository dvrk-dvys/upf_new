WITH min_customer as (
select min(MESSAGE_SENT_TIME) as timestamp_of_first_customer_message, order_id
from customer_courier_chat_messages
where SENDER_APP_TYPE = 'Customer iOS' or SENDER_APP_TYPE = 'Customer Android'
group by order_id),

min_courier as (
select min(MESSAGE_SENT_TIME) as timestamp_of_first_courier_message, order_id
from customer_courier_chat_messages
where SENDER_APP_TYPE = 'Courier iOS' or SENDER_APP_TYPE = 'Courier Android'
group by order_id),

customer_count as (
select count(from_id) as number_of_messages_from_customer, order_id
from customer_courier_chat_messages
where SENDER_APP_TYPE = 'Customer iOS' or SENDER_APP_TYPE = 'Customer Android'
group by from_id, order_id),

courier_count as (
select count(from_id) as number_of_messages_from_courier, order_id
from customer_courier_chat_messages
where SENDER_APP_TYPE = 'Courier iOS' or SENDER_APP_TYPE = 'Courier Android'
group by from_id, order_id),

first_message as (
	select
	CASE
		WHEN d.timestamp_of_first_courier_message > a.timestamp_of_first_customer_message THEN "customer"
		WHEN d.timestamp_of_first_courier_message < a.timestamp_of_first_customer_message THEN "courier"
	END as first_message_sender,
	CASE
		WHEN d.timestamp_of_first_courier_message > a.timestamp_of_first_customer_message THEN a.timestamp_of_first_customer_message
		WHEN d.timestamp_of_first_courier_message < a.timestamp_of_first_customer_message THEN d.timestamp_of_first_courier_message
	END as first_message_timestamp,
    a.order_id
    
    from min_customer a
    LEFT JOIN min_courier as d on d.order_id = a.order_id

    ),

time_elapsed_first_message as (
	SELECT *
		FROM (
			SELECT order_id, message_sent_time, ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY message_sent_time ASC) n
			FROM customer_courier_chat_messages
			) i
	WHERE i.n = 2),
    
last_message as (
	select max(MESSAGE_SENT_TIME) as most_recent_message, order_id
	from customer_courier_chat_messages
    group by order_id
	),
    
last_stage as (
	select x.order_stage, x.order_id
	from customer_courier_chat_messages as x
	inner join last_message as i on i.order_id = x.order_id and x.MESSAGE_SENT_TIME = i.most_recent_message
	)
    


select 
a.ORDER_ID,
b.city_code,
c.timestamp_of_first_customer_message,
d.timestamp_of_first_courier_message,
e.number_of_messages_from_customer,
f.number_of_messages_from_courier,
g.first_message_sender,
g.first_message_timestamp,
TIMESTAMPDIFF(SECOND,g.first_message_timestamp,h.message_sent_time) as time_elapsed_first_message_secs,
i.most_recent_message,
j.order_stage as last_stage

from customer_courier_chat_messages as a
LEFT JOIN orders as b on b.order_id = a.order_id
LEFT JOIN min_customer as c on c.order_id = a.order_id
LEFT JOIN min_courier as d on d.order_id = a.order_id
LEFT JOIN customer_count as e on e.order_id = a.order_id
LEFT JOIN courier_count as f on f.order_id = a.order_id
LEFT JOIN first_message as g on g.order_id = a.order_id
LEFT JOIN time_elapsed_first_message as h on h.order_id = a.order_id
LEFT JOIN last_message as i on i.order_id = a.order_id
LEFT JOIN last_stage as j on j.order_id = a.order_id

;

