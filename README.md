
## Part 1. Run Debezium and Kafka Connect in Docker Compose

Start only the Postgres, Zookeeper, Kafka, Kafka UI, and Kafka Connect services with the following command (in background mode):

```bash
docker-compose up -d postgres zookeeper kafka kafka-ui kafka-connect
```

Once all the components run, you can register Postgres Debezium connector to start streaming the training data from Postgres database into Kafka:

```bash
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @debezium/register-postgres-flink.json
```

To check the status of the connector, run:

```bash
curl http://localhost:8083/connectors/?expand=status | jq
```

Login to Postgres database with the following command:

```bash
docker-compose exec postgres psql -U postgres
```

Copy from the `postgres/inserts.sql` file and paste it into the terminal to insert some data into the tables.

To see the created topics in Kafka, open the Kafka UI at http://localhost:8080.


To stop the containers, run (removing the volumes):

```bash
docker-compose down -v
```

## Part 2. Run Flink in Docker Compose


Start all the services with the following command (in background mode):

```bash
docker-compose up -d --build
```


To run an interactive SQL Client, run:

```bash
docker-compose run sql-client
```

Copy the content from `flink/kafka-to-iceberg.sql` and paste it into the terminal to run the SQL queries.
