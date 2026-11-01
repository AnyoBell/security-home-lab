#!/bin/bash
set -e
source .env
docker compose up -d elasticsearch
until curl -s -u elastic:$ELASTIC_PASSWORD http://localhost:9200 >/dev/null; do sleep 5; done
echo "Elasticsearch is up"
curl -s -u elastic:$ELASTIC_PASSWORD -X POST "http://localhost:9200/_security/user/kibana_system/_password" -H "Content-Type: application/json" -d "{\"password\":\"$KIBANA_PASSWORD\"}"
echo
docker compose up -d
docker compose ps
