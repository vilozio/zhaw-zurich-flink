-- Color schema.
SET 'sql-client.display.color-schema' = 'Dracula';
-- Set the parallelism.
SET parallelism.default = 2;

CREATE TABLE t_k_orders
  (
    `payload` ROW(
        order_id           STRING,
        customer_id        STRING,
        order_number       INT,
        product            STRING,
        backordered        BOOLEAN,
        cost               FLOAT,
        description        STRING,
        create_ts          BIGINT,
        credit_card_number STRING,
        discount_percent   INT
    )
  ) WITH (
    'connector' = 'kafka',
    'topic' = 'postgres.public.orders',
    'properties.bootstrap.servers' = 'kafka:9092',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json'
  );


SET 'execution.checkpointing.interval' = '60sec';
SET 'pipeline.operator-chaining.enabled' = 'false';

-- Create a running streaming job to write to Iceberg.
CREATE TABLE t_i_orders 
  WITH (
  'connector' = 'iceberg',
  'catalog-type' = 'hive',
  'catalog-name' = 'dev',
  'warehouse' = 's3a://warehouse',
  'hive-conf-dir' = './conf')
  AS 
  SELECT 
    `payload`.order_id as order_id,
    `payload`.customer_id as customer_id,
    `payload`.order_number as order_number,
    `payload`.product as product,
    `payload`.backordered as backordered,
    `payload`.cost as cost,
    `payload`.description as description,
    `payload`.create_ts as create_ts,
    `payload`.credit_card_number as credit_card_number,
    `payload`.discount_percent as discount_percent
  FROM t_k_orders;


-- After 60 seconds, check the Iceberg table.
-- This will be another running query.
SELECT * FROM t_i_orders;
