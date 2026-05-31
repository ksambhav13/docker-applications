CONSISTENCY LOCAL_QUORUM;

CREATE KEYSPACE IF NOT EXISTS app
WITH replication = {
  'class': 'NetworkTopologyStrategy',
  'dc1': 3
}
AND durable_writes = true;
