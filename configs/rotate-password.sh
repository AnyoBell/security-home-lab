#!/bin/bash
set -e
source .env
NEW=$(openssl rand -hex 16)
RESP=$(docker compose exec -T elasticsearch curl -s --cacert config/certs/ca/ca.crt -u "elastic:${ELASTIC_PASSWORD}" -X POST https://localhost:9200/_security/user/elastic/_password -H "Content-Type: application/json" -d "{\"password\":\"${NEW}\"}")
if [ "$RESP" != "{}" ]; then echo "Failed: $RESP"; exit 1; fi
sed -i "s/^ELASTIC_PASSWORD=.*/ELASTIC_PASSWORD=${NEW}/" .env
docker compose up -d --force-recreate logstash
echo "Done. New password is in .env"
