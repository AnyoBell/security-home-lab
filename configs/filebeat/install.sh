#!/bin/bash
set -e
ARCH=$(dpkg --print-architecture)
sudo apt update
sudo apt install -y rsyslog
sudo systemctl enable --now rsyslog
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.15.0-${ARCH}.deb
sudo dpkg -i filebeat-8.15.0-${ARCH}.deb
sudo cp filebeat.yml /etc/filebeat/filebeat.yml
sudo chown root:root /etc/filebeat/filebeat.yml
sudo filebeat test output
sudo systemctl enable --now filebeat
