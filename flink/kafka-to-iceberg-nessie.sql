-- Color schema.
SET 'sql-client.display.color-schema' = 'Dracula';
-- Set the parallelism.
SET parallelism.default = 2;

-- Create a Kafka source table.
CREATE TABLE t_k_orders
  (
    -- Data is located under the `payload` field in Debezium format.
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


-- Create a Nessie Iceberg catalog.
-- https://projectnessie.org/iceberg/flink/
CREATE CATALOG nessie WITH (
  'type' = 'iceberg',
  'catalog-impl' = 'org.apache.iceberg.nessie.NessieCatalog',  -- Use Nessie Catalog implementation.
  'io-impl' = 'org.apache.iceberg.aws.s3.S3FileIO',
  'authentication.type' = 'none',
  'uri' = 'http://nessie:19120/api/v1',
  'ref' = 'main',
  'client.assume-role.region'='us-east-1',
  'warehouse' = 's3a://warehouse',
  's3.path-style-access' = 'true',    -- Required for Minio
  's3.endpoint' = 'http://minio:9000'
);

-- Create a database namespace.
CREATE DATABASE nessie.warehouse;

-- Switch to the Nessie Iceberg catalog.
USE CATALOG nessie;
USE warehouse;

-- Create a running streaming job to write to Iceberg.
-- This will be a long-running query that will not block the terminal.
-- It might take few seconds to start.
CREATE TABLE `nessie`.`warehouse`.t_i_orders 
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
  FROM `default_catalog`.`default_database`.t_k_orders;


-- Optional, after 60 seconds, check the Iceberg table.
-- This will be another running query.
SELECT * FROM `nessie`.`warehouse`.t_i_orders;
