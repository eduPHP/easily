
EASILY_ROOT="${HOME}/code/docker"
rootpem="${EASILY_ROOT}/config/nginx/rootCA.pem"
rootkey="${EASILY_ROOT}/config/nginx/rootCA.key"

if [ ! -f $rootpem ]; then
  echo "$rootpem doesn't exist, creating it."
  sh $EASILY_ROOT/scripts/rootCA.sh
fi

# from https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/
if [ "$#" -eq  "0" ]; then
     echo "which domain would you like to use?"
     read domain
     project=$domain
 else
     project=$1
     domain=$1
 fi

path="${EASILY_ROOT}/projects/${project}/certs"
mkdir -p $path

 if [ "$#" -eq  "2"  ]; then
   domain=$2
 fi

keyfile="${path}/${domain}.test.key"
csrfile="${path}/${domain}.test.csr"
crtfile="${path}/${domain}.test.crt"
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
DNS.1 = ${domain}.test" > $extfile

openssl x509 -req \
  -in $csrfile \
  -CA $rootpem \
  -CAkey $rootkey \
  -CAcreateserial -out $crtfile \
  -days 825 \
  -sha256 \
  -extfile $extfile \
  -passin pass:secret