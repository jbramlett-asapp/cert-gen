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
	ORGANIZATION=PLATFORM
fi

if [ -z "$SAN" ];
then
	SAN=*DNS:*.local
fi


USAGE="Usage: $0 root_ca.crt-file root_ca.key-file output_file_root"

if [ "$#" -lt "3" ]
then
  echo "$USAGE"
  exit 1
fi

CA_CERT=$1
CA_KEY=$2
OUTPUT_FILE_ROOT=$3

SUBJECT="/C=US/ST=New York/L=New York/O=$ORGANIZATION/OU=$ORGANIZATION_UNIT/CN=$COMMON_NAME"

openssl req -new -sha256 \
    -key $OUTPUT_FILE_ROOT.key \
    -subj "$SUBJECT" \
    -reqexts SAN \
    -config <(cat /etc/ssl/openssl.cnf \
        <(printf "\n[SAN]\nsubjectAltName=$SAN")) \
    -out $OUTPUT_FILE_ROOT.csr


# openssl req -new -config cert.conf -subj "CN=mytestdomain.com" -keyout mydomain.com.key -out mydomain.com.csr

#openssl req -in $OUTPUT_FILE_ROOT.csr -noout -text

openssl x509 -req -in $OUTPUT_FILE_ROOT.csr -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out $OUTPUT_FILE_ROOT.pem -days 3650 -sha256

#openssl x509 -in mydomain.com.crt -text -noout