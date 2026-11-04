#!/bin/bash
set -e
for k in ENC_KEY_SAVED ENC_KEY_SECURITY ENC_KEY_REPORTING; do
  grep -q "^$k=" .env || echo "$k=$(openssl rand -hex 32)" >> .env
done
echo "Encryption keys in .env:"
grep -c "^ENC_KEY" .env
