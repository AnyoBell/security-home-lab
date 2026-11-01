#!/bin/bash
set -e
if [ -f .env ]; then echo ".env already exists, not overwriting"; exit 1; fi
cat > .env <<EOF
ELASTIC_VERSION=8.15.0
ELASTIC_PASSWORD=$(openssl rand -hex 16)
KIBANA_PASSWORD=$(openssl rand -hex 16)
ES_HEAP=2g
LISTEN_IP=$(hostname -I | awk '{print $1}')
EOF
chmod 600 .env
cat .env
