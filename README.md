# Security Home Lab

An attack-and-defend lab on UTM. An Elastic SIEM collects logs from a Kali attacker and a deliberately vulnerable web app (OWASP Juice Shop), and detection rules map what it sees to MITRE ATT&CK.

Full write-ups: [anyobell.io](https://anyobell.io)

## Architecture

| Role | Tool |
|------|------|
| Hypervisor | UTM |
| Attacker | Kali Linux, with Filebeat shipping its logs |
| SIEM host | Ubuntu Server 24.04 VM running Elasticsearch, Logstash, and Kibana in Docker |
| Target | OWASP Juice Shop behind Nginx, on the SIEM VM (port 8080) |

Log flow:

- Kali: Filebeat -> Logstash (5044)
- Juice Shop: Nginx -> Docker syslog driver -> Logstash (UDP 5514)
- Logstash parses the web logs into fields (client_ip, http_path, http_status) -> Elasticsearch (HTTPS) -> Kibana

## Quick start (SIEM VM)

```bash
git clone https://github.com/AnyoBell/security-home-lab.git
cd security-home-lab/configs
bash setup-env.sh        # generates passwords in .env (git-ignored)
bash add-tls-env.sh      # adds Kibana encryption keys to .env
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
docker compose up -d     # first start takes several minutes
docker compose -p juiceshop -f juice-shop.yml up -d
```

Open Kibana at `http://<SIEM-VM-IP>:5601` and log in as `elastic` (password in `.env`). Create a data view for `homelab-logs-*`.

## Add Kali as a log source

On Kali, from `configs/filebeat`, set the SIEM VM's IP in `filebeat.yml`, then run `bash install.sh`.

## Detections

| Rule | MITRE ATT&CK | Status |
|------|--------------|--------|
| Juice Shop SQL injection probe (encoded quote in request) | T1190 Exploit Public-Facing Application | Working |
| Juice Shop login brute force (threshold on failed logins) | T1110 Brute Force | Working |

## Security notes

- Keep the whole lab on an isolated network. Juice Shop is intentionally vulnerable.
- Secrets live only in `.env`, which is git-ignored. Never commit it.
- Elasticsearch uses HTTPS with a lab-generated certificate authority. Kibana itself is plain HTTP on the lab IP, and the syslog input has no authentication, which is fine for an isolated lab only.

## Lessons learned

- Kibana detection rules need HTTPS between Kibana and Elasticsearch, plus an encryption key.
- Rules only look back a few minutes, so send test traffic after enabling the rule.
- Parse logs into fields before writing detections.

## Roadmap

- [x] ELK stack with HTTPS
- [x] Kali and Juice Shop logs flowing in
- [x] First ATT&CK-mapped detection (T1190)
- [x] Brute-force detection (T1110)
