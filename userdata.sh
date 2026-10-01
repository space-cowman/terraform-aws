#!/bin/bash
apt-get update -y
apt-get install -y apache2

# IMDSv2-safe way to get instance metadata
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)

echo "<h1>Hello from $INSTANCE_ID</h1>" > /var/www/html/index.html
systemctl enable --now apache2
