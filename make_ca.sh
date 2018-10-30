#!/usr/bin/env bash
if [ -z "$COMMON_NAME" ];
then
	COMMON_NAME=ASAPPGeneratedCert
fi

if [ -z "$ORGANIZATION" ]; 
then
	ORGANIZATION="ASAPP"
fi

if [ -z "$ORGANIZATION_UNIT" ]; 
then
	ORGANIZATION_UNIT="PLATFORM"
fi

if [ "$#" -lt "1" ];
then
	CA_ROOT=rootCA
else
	CA_ROOT=$1
fi

CERT_FILE="$CA_ROOT"_certificate.pem
KEY_FILE="$CA_ROOT"_key.pem
SUBJECT="/C=US/ST=NY/L=New York/O=$ORGANIZATION/OU=$ORGANIZATION_UNIT/CN=$COMMON_NAME"

CONFIG="
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

echo Generating Root CA and Key
openssl req -config <(echo "$CONFIG") -x509 -days 3650 -newkey rsa:2048 -keyout $KEY_FILE -out $CERT_FILE -outform PEM -subj "$SUBJECT" -nodes

#openssl req -config openssl.conf -x509 -days 3650 -newkey rsa:2048 -keyout $KEY_FILE -out $CERT_FILE -outform PEM -subj "$SUBJECT" -nodes