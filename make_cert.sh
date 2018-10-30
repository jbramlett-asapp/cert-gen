#!/usr/bin/env bash

if [ -z "$COMMON_NAME" ];
then
	COMMON_NAME=$HOSTNAME
fi

if [ -z "$ORGANIZATION" ]; 
then
	ORGANIZATION=ASAPP
fi

if [ -z "$ORGANIZATION_UNIT" ]; 
then
	ORGANIZATION_UNIT=PLATFORM
fi

if [ -z "$SAN" ];
then
	SAN="DNS:localhost,DNS:*.local,DNS:$HOSTNAME,DNS:*.dc,DNS:rabbitmq"
fi

USAGE="Usage: $0 root_ca.crt-file root_ca.key-file output_file_root"

if [ "$#" -lt "3" ];
then
  echo "$USAGE"
  exit 1
fi

CA_CERT=$1
CA_KEY=$2
OUTPUT_FILE_ROOT=$3

GEN_WORKDIR=./wip
if [ -d $GEN_WORKDIR ] ; then
	rm -rf $GEN_WORKDIR
fi
mkdir $GEN_WORKDIR


CERT_DIR="$GEN_WORKDIR"/cert
CERT_DB="$GEN_WORKDIR"/index.txt
CERT_DB_ATTR="$CERT_DB".attr
SERIAL="$GEN_WORKDIR"/serial

SUBJECT="/C=US/ST=NY/L=New York/O=$ORGANIZATION/OU=$ORGANIZATION_UNIT/CN=$COMMON_NAME"

if [ -e $CERT_DB ] ; then
    rm $CERT_DB
fi

if [ -e $CERT_DB_ATTR ] ; then
    rm $CERT_DB_ATTR
fi

if [ -e $SERIAL ] ; then
    rm $SERIAL
fi

if [ -d $CERT_DIR ] ; then
	rm -rf $CERT_DIR
fi


mkdir $CERT_DIR
touch $CERT_DB
touch $CERT_DB_ATTR
echo "01" > $SERIAL

CONFIG="
[ ca ]
default_ca = root_ca

[ root_ca ]
certificate   = $CA_CERT
database      = $CERT_DB
new_certs_dir = $CERT_DIR
private_key   = $CA_KEY
serial        = $SERIAL

default_crl_days = 7
default_days     = 1825
default_md       = sha256

policy          = root_ca_policy
x509_extensions = certificate_extensions

[ root_ca_policy ]
commonName = supplied
stateOrProvinceName = optional
countryName = optional
emailAddress = optional
organizationName = optional
organizationalUnitName = optional
domainComponent = optional

[ certificate_extensions ]
basicConstraints = CA:false

[ server_extensions ]
basicConstraints = CA:false
keyUsage         = digitalSignature,keyEncipherment
extendedKeyUsage = 1.3.6.1.5.5.7.3.1
subjectAltName   = $SAN

[ req ]
default_bits       = 4096
default_md         = sha256
prompt             = yes 
distinguished_name = root_ca_distinguished_name
x509_extensions    = root_ca_extensions

[ root_ca_distinguished_name ]
commonName = hostname

[ root_ca_extensions ]
basicConstraints = CA:true
keyUsage         = keyCertSign, cRLSign
"

KEY_FILE="$OUTPUT_FILE_ROOT"_key.pem
CERT_FILE="$OUTPUT_FILE_ROOT"_certificate.pem
CSR_FILE="$OUTPUT_FILE_ROOT".csr

echo "Generating new key"
openssl genrsa -out $KEY_FILE 2048

echo "Generating Cert"
openssl req -new \
    -config <(echo "$CONFIG") \
    -key $KEY_FILE \
    -keyout $CERT_FILE \
    -out $CSR_FILE \
    -days 3650 \
    -outform PEM \
    -subj "$SUBJECT" \
    -nodes

echo "Signing Cert"
openssl ca \
    -config <(echo "$CONFIG") \
	-days 3650 \
	-cert $CA_CERT \
	-keyfile $CA_KEY \
	-in $CSR_FILE \
	-out $CERT_FILE \
	-outdir $CERT_DIR \
	-notext \
	-batch \
	-extensions server_extensions

# openssl req -new -config cert.conf -subj "CN=mytestdomain.com" -keyout mydomain.com.key -out mydomain.com.csr

#openssl req -in $OUTPUT_FILE_ROOT.csr -noout -text

# openssl x509 -req -in $OUTPUT_FILE_ROOT.csr -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -outform PEM -out $OUTPUT_FILE_ROOT.pem -days 3650 -sha256

#openssl x509 -in mydomain.com.crt -text -noout