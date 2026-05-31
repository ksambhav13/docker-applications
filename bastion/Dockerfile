FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    redis-tools \
    postgresql-client \
    python3 \
    python3-venv \
    openjdk-21-jre-headless \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# cqlsh for Cassandra 5.x — isolated in a venv to avoid system-package conflicts
RUN python3 -m venv /opt/cqlsh-env \
    && /opt/cqlsh-env/bin/pip install --no-cache-dir cqlsh \
    && ln -s /opt/cqlsh-env/bin/cqlsh /usr/local/bin/cqlsh

# Kafka CLI tools — same version as the kafka-cluster compose
ARG KAFKA_VERSION=4.2.1
RUN wget -q "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz" \
    && tar -xzf "kafka_2.13-${KAFKA_VERSION}.tgz" -C /opt \
    && ln -s "/opt/kafka_2.13-${KAFKA_VERSION}" /opt/kafka \
    && rm "kafka_2.13-${KAFKA_VERSION}.tgz"

ENV PATH="$PATH:/opt/kafka/bin"

WORKDIR /workspace
CMD ["bash"]
