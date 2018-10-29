
openssl genrsa -out rootCA.key 4096

openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt -subj "/C=US/ST=New York/L=New York/O=ASAPP/OU=Platform/CN=asapp.local"