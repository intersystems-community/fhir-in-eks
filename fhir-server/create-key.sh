#!/bin/sh
# Creates self-signed keys suitable for use communicating from the webgateway to the superserver and other use cases

IP_ADDR=`ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`
TLS_PASS=`openssl rand -hex 26`
OPENSSL_CNF=${PWD}/openssl.config

TLS_DIR=$1
if [ -z "$TLS_DIR" ]; then
    TLS_DIR=${PWD}
fi
if ! mkdir -p $TLS_DIR ; then
    exit 1
fi
cd $TLS_DIR

if [ ! -f "$OPENSSL_CNF" ]; then
    echo "Error: File $OPENSSL_CNF not found" 1>&2
    exit 1
fi

echo 'Generating keys for TLS authentication.'

# CA Private / Public Keys
openssl genrsa -aes256 -passout pass:$TLS_PASS -out ca.key 4096
openssl req -new -passin pass:$TLS_PASS -passout pass:$TLS_PASS -x509 -days 3650 -key ca.key -sha256 -out ca.pem -subj "/C=US/ST=Massachusetts/L=Cambridge/O=Intersystems/OU=Development/CN=$IP_ADDR"

# Server key / CSR
openssl genrsa -out tls.key 4096
openssl req -subj "/CN=$IP_ADDR" -sha256 -new -key tls.key -out server.csr

# Sign the public key
echo subjectAltName = IP:$IP_ADDR > extfile.cnf
openssl x509 -req -passin pass:$TLS_PASS -days 3650 -sha256 -in server.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out tls.crt -extfile extfile.cnf
  
#Cleanup & Protect the keys / CA
rm -v server.csr ca.srl extfile.cnf
chmod -v 0644 ca.key ca.pem tls.key tls.crt

echo 'Done.  Now create a kubernetes secret'

exit 0
