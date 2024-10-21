
# Streaming Data and Data Lakehouse Architectures

This repository contains the code for the "Streaming Data and Data Lakehouse Architectures" workshop. 

The workshop is divided into parts:

1. Debezium and Kafka Connect
2. Flink with Kafka
3. Flink with Iceberg
4. Flink with Nessie for data versioning



## Prerequisites

Clone this repository and navigate to the `zhaw-zurich-flink` folder.


If you don't have Docker installed, you can download it from [official website](https://www.docker.com/products/docker-desktop).

You need Docker and Docker Compose to run the workshop.

### On Windows

If you are using Windows, you need to install [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install-win10) 
and [Docker Desktop](https://www.docker.com/products/docker-desktop).

Check that you have WSL2 installed, open the search bar and type `Ubuntu` and press Enter. You should see the Ubuntu terminal.

Check the docker version with the following command:

```bash
docker version
```

Check the docker-compose version with the following command:

```bash
docker-compose version
```

If you don't have Docker Compose installed, you can install it with the following command:

```bash
sudo apt-get install docker docker-compose
```

On Windows WSL2 to run docker commands you need to start a docker daemon in background.
Open a separate terminal and run the following command and keep it running:

```bash
sudo dockerd
```

Install the `jq` command-line JSON processor and `curl` with the following command:

```bash
sudo apt-get install jq curl
```


### On Mac

If you are using Mac, you can install Docker Desktop from the [official website](https://www.docker.com/products/docker-desktop).

Check the docker version with the following command:

```bash
docker version
```

Check the docker-compose version with the following command:

```bash
docker-compose version
```

Install the `jq` command-line JSON processor and `curl` with the following command (you need to 
have [Homebrew](https://brew.sh/) installed):

```bash
brew install jq curl
```




## Part 1. Run Debezium and Kafka Connect in Docker Compose

Start only the Postgres, Zookeeper, Kafka, Kafka UI, and Kafka Connect services with the following command (in background mode):

```bash
docker-compose up -d postgres zookeeper kafka kafka-ui kafka-connect
```

Once all the components run, you can register Postgres Debezium connector to start streaming CDC from Postgres database into Kafka:

```bash
curl -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @debezium/register-postgres-flink.json
```

If you get an error, wait a few seconds and try again, as the Kafka Connect might not be ready yet.

To check the status of the connector, run:

```bash
curl http://localhost:8083/connectors/?expand=status | jq
```

You should see something like this:

```json
{
  "connector-flink": {
    "status": {
      "name": "connector-flink",
      "connector": {
        "state": "RUNNING",
        "worker_id": "172.30.0.16:8083"
      },
      "tasks": [
        {
          "id": 0,
          "state": "RUNNING",
          "worker_id": "172.30.0.16:8083"
        }
      ],
      "type": "source"
    }
  }
}
```

Login to Postgres database with the following command:

```bash
docker-compose exec postgres psql -U postgres
```

You will see the Postgres prompt where you can run SQL queries.

```
psql (15.8 (Debian 15.8-1.pgdg120+1))
Type "help" for help.

postgres=#
```

Copy from the `postgres/inserts.sql` file and paste it into the terminal to insert some data into the tables.
Press Enter to run query and then type `\q` to exit the Postgres terminal.

To see the created topics in Kafka, open the Kafka UI at http://localhost:8080.
Go to the Topics tab where you should see the `postgres.public.customers` and `postgres.public.orders` topics.
Open a topic and click on the `Messages` tab to see the messages in JSON format.


**TRY IT OUT:**

1. Try to update a record in the `customers` table in Postgres and see the changes in the Kafka topic.
2. Try to delete a record in the `orders` table in Postgres. What happens in the Kafka topic?


To stop the containers, run (removing the volumes to remove the data as well):

```bash
docker-compose down -v
```



## Part 2. Run Flink with Kafka in Docker Compose


Start the services with the following command. This will start Zookeeper, Kafka, Kafka UI, Flink JobManager and TaskManager.

```bash
docker-compose up -d --build zookeeper kafka kcat kafka-ui jobmanager taskmanager
```

Create Kafka topics with the following commands:

```bash
docker-compose exec kafka bin/kafka-topics.sh --create --topic customers --bootstrap-server kafka:9092 --partitions 1 --replication-factor 1
docker-compose exec kafka bin/kafka-topics.sh --create --topic orders --bootstrap-server kafka:9092 --partitions 1 --replication-factor 1
```

List the created topics

```bash
docker-compose exec kafka bin/kafka-topics.sh --list --bootstrap-server kafka:9092
```

Use `kcat` to produce messages to the customers topic

```bash
echo '{"customer_id": "550e8400-e29b-41d4-a716-446655440000", "name": "John Doe", "birthday": "1985-06-15", "direct_subscription": true, "membership_level": "pro", "shipping_address": "1234 Elm St, Springfield, IL", "activation_date": "2024-10-20 10:45:00"}' | docker-compose exec -T kcat kcat -b kafka:9092 -t customers -P

echo '{"customer_id": "7c62c57b-3d43-470b-b5f3-efa56c8d14ad", "name": "Jane Smith", "birthday": "1990-03-22", "direct_subscription": false, "membership_level": "elite", "shipping_address": "5678 Maple St, Boston, MA", "activation_date": "2024-10-19 14:20:30"}' | docker-compose exec -T kcat kcat -b kafka:9092 -t customers -P

echo '{"customer_id": "e0b70fdc-9cd4-44f8-baca-962f1b58273b", "name": "Alice Johnson", "birthday": "1972-12-09", "direct_subscription": true, "membership_level": "free", "shipping_address": "7890 Oak St, Dallas, TX", "activation_date": "2024-10-18 08:05:45"}' | docker-compose exec -T kcat kcat -b kafka:9092 -t customers -P
```


To run an interactive FLink SQL Client, run:

```bash
docker-compose run sql-client
```

You will see the Flink SQL Client prompt where you can run SQL queries.

```
    ______ _ _       _       _____  ____  _         _____ _ _            _  BETA
   |  ____| (_)     | |     / ____|/ __ \| |       / ____| (_)          | |
   | |__  | |_ _ __ | | __ | (___ | |  | | |      | |    | |_  ___ _ __ | |_
   |  __| | | | '_ \| |/ /  \___ \| |  | | |      | |    | | |/ _ \ '_ \| __|
   | |    | | | | | |   <   ____) | |__| | |____  | |____| | |  __/ | | | |_
   |_|    |_|_|_| |_|_|\_\ |_____/ \___\_\______|  \_____|_|_|\___|_| |_|\__|

        Welcome! Enter 'HELP;' to list all available commands. 'QUIT;' to exit.

Command history file path: /opt/flink/.flink-sql-history

Flink SQL> 
```

(Optional) run this to set up a color schema

```sql
SET 'sql-client.display.color-schema' = 'Dracula';
```

Create a Flink table for the customers topic

```sql
CREATE TABLE customers (
    customer_id STRING,
    name STRING,
    birthday DATE,
    direct_subscription BOOLEAN,
    membership_level STRING,
    shipping_address STRING,
    activation_date TIMESTAMP(3)
) WITH (
    -- Connector type is Kafka.
    'connector' = 'kafka',
    -- Kafka topic to read or write.
    'topic' = 'customers',
    -- Kafka server properties.
    'properties.bootstrap.servers' = 'kafka:9092',
    'properties.group.id' = 'testGroup',
    -- Messages format.
    'format' = 'json',
    -- Scan mode 'earliest-offset' to read from the beginning of the topic.
    'scan.startup.mode' = 'earliest-offset'
);
```

*Note: When you exit the sql session the table definition will be lost, because we don't have a persistent 
catalog yet.*


Query the customers table

```sql
SELECT * FROM customers;
```

This will open a table view where you can see the data from the topic.
The `SELECT` statement will keep running in streaming mode and show the data as it arrives.

You can also open the Flink dashboard at http://localhost:8081 to see the running job and the graph
of the data flow.

**TRY IT OUT:**

1. Try to produce more messages to the customers topic in a separate terminal and see the streaming query.

2. Try to change the SQL query to aggregate the data by `membership_level` and count the number of customers. Produce more messages to the topic and see the results.


To stop the streaming query, press `Q` (You can also cancel it from Flink dashboard).

To exit the Flink SQL Client, type `QUIT;` and press Enter.

To stop the containers, run (removing the volumes to remove the data as well):

```bash
docker-compose down -v
```

