#!/bin/bash
set -e

# Fix Kali's missing archive signing key
sudo wget https://archive.kali.org/archive-keyring.gpg -O /usr/share/keyrings/kali-archive-keyring.gpg
curl -fsSL https://archive.kali.org/archive-key.asc -o kali-archive-key.asc
sudo gpg --dearmor < kali-archive-key.asc | sudo tee /etc/apt/trusted.gpg.d/kali.gpg > /dev/null
rm kali-archive-key.asc

# Install rsyslog and Filebeat
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
