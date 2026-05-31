# docker-applications

Standalone Docker Compose configurations for running common data infrastructure locally. Each stack lives in its own directory and is managed independently — no shared orchestration layer.

## Stacks

| Directory | Stack | Host Ports |
|---|---|---|
| `redis/` | Redis 7.2 (single node, AOF) | 6379 |
| `redis-cluster/` | Redis cluster (3 primary + 3 replica) | 7000–7005 |
| `postgres/` | PostgreSQL 16 + pgvector | 5432 |
| `cassandra-cluster/` | Cassandra 3-node cluster | 9042–9044 |
| `elasticsearch-cluster/` | Elasticsearch 3-node + Kibana | 9200, 5601 |
| `kafka-cluster/` | Kafka KRaft (3 controllers + 3 brokers) | 29092, 39092, 49092 |

## Usage

```bash
# Start a stack
docker compose -f <dir>/docker-compose.yml up -d

# Tear down and remove volumes
docker compose -f <dir>/docker-compose.yml down -v

# Check health
docker compose -f <dir>/docker-compose.yml ps
```

## Bastion Container

A single tools container with all CLIs pre-installed: `redis-cli`, `psql`, `cqlsh`, `curl`, and the Kafka CLI suite (`kafka-topics.sh`, `kafka-console-producer.sh`, etc.).

```bash
./bastion.sh
```

Or via Docker Compose:

```bash
docker compose -f bastion/docker-compose.yml run --rm bastion
```

Once inside, all running stacks are reachable via `host.docker.internal`:

| Stack | Command |
|---|---|
| Redis (single) | `redis-cli -h host.docker.internal -p 6379` |
| Redis cluster | `redis-cli -c -h host.docker.internal -p 7000` |
| PostgreSQL | `psql -h host.docker.internal -U postgres -d app` (password: `postgres`) |
| Cassandra | `cqlsh host.docker.internal 9042` |
| Elasticsearch | `curl http://host.docker.internal:9200/_cluster/health` |
| Kafka | `kafka-topics.sh --bootstrap-server host.docker.internal:29092 --list` |

## Stack Details

### Redis (single node) — `redis/`

Redis 7.2 with AOF persistence. Data survives container restarts via a named volume.

### Redis Cluster — `redis-cluster/`

Six-node cluster (3 primary, 3 replica) on ports 7000–7005. An init container creates the cluster topology after all nodes are healthy, and guards against re-initialization by checking `cluster_state:ok` before running `--cluster create`.

### PostgreSQL — `postgres/`

PostgreSQL 16 with the `pgvector` extension enabled. The `vector` extension is activated via an `initdb` script mounted at `/docker-entrypoint-initdb.d`.

- **Database:** `app`
- **User / Password:** `postgres` / `postgres`

### Cassandra Cluster — `cassandra-cluster/`

Three-node Cassandra cluster using `GossipingPropertyFileSnitch` (dc1/rack1). An init container creates an `app` keyspace with `NetworkTopologyStrategy` RF=3 once all nodes pass health checks.

### Elasticsearch Cluster — `elasticsearch-cluster/`

Three Elasticsearch nodes (all master-eligible + data) plus Kibana. xpack security is disabled. An init container sets the default replica count to 1 after the cluster is healthy.

- **Elasticsearch:** `http://localhost:9200`
- **Kibana:** `http://localhost:5601`

### Kafka Cluster — `kafka-cluster/`

KRaft mode — no ZooKeeper. Three dedicated controller nodes and three broker nodes. Brokers expose three listener types:

- `PLAINTEXT` (port 19092) — internal broker-to-broker traffic
- `PLAINTEXT_HOST` (ports 29092/39092/49092) — host machine access via `localhost`
- `CONTROLLER` (port 9093) — controller quorum (controllers only)

Default replication factor: 3, min ISR: 2.
