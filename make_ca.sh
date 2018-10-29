#!/usr/bin/env bash

openssl genrsa -out rootCA.key 4096

if [ -z "$COMMON_NAME" ];
then
	COMMON_NAME=$HOSTNAME
fi

if [ -z "$ORGANIZATION" ]; 
then
	ORGANIZATION="ASAPP"
fi

if [ -z "$ORGANIZATION_UNIT" ]; 
then
	ORGANIZATION_UNIT="PLATFORM"
fi

SUBJECT="/C=US/ST=NY/L=New York/O=$ORGANIZATION/OU=$ORGANIZATION_UNIT/CN=$COMMON_NAME"

openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt -subj "$SUBJECT"