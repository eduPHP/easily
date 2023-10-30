#!/usr/bin/zsh
EASILY_ROOT="${HOME}/code/docker"

path="${EASILY_ROOT}/config/nginx/certs"

rootpem="${EASILY_ROOT}/config/nginx/certs/rootCA.pem"
rootkey="${EASILY_ROOT}/config/nginx/certs/rootCA.key"

if [ ! -f $rootpem ]; then
  echo "$rootpem doesn't exist, creating it."
  sh $EASILY_ROOT/scripts/rootCA.sh
fi

# from https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/
if [ "$#" -eq  "0" ]
   then
     echo "which domain would you like to use?"
     read domain
 else
     domain=$1
 fi

keyfile="${path}/${domain}.key"
csrfile="${path}/${domain}.csr"
crtfile="${path}/${domain}.crt"
extfile="${path}/${domain}.ext"

openssl genrsa -out $keyfile 2048
openssl req -new \
  -key $keyfile \
  -out $csrfile \
  -subj "/C=CA/ST=Canada/L=Canada/O=IT/CN=server.example.com"
echo "authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${domain}" > $extfile

openssl x509 -req \
  -in $csrfile \
  -CA $rootpem \
  -CAkey $rootkey \
  -CAcreateserial -out $crtfile \
  -days 825 \
  -sha256 \
  -extfile $extfile \
  -passin pass:secret