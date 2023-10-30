#!/usr/bin/env bash

EASILY_ROOT="${HOME}/code/docker"

# from https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/
echo "Generating rootCA..."

openssl genrsa -des3 \
  -passout pass:secret \
  -out "${EASILY_ROOT}/config/nginx/certs/rootCA.key" 2048

openssl req -x509 -new -nodes \
  -key "${EASILY_ROOT}/config/nginx/certs/rootCA.key" \
  -sha256 -days 1825 \
  -passin pass:secret \
  -out "${EASILY_ROOT}/config/nginx/certs/rootCA.pem" \
  -subj "/C=CA/ST=Canada/L=Canada/O=IT/CN=server.example.com"
