openssl req -new -sha256 \
    -key mydomain.com.key \
    -subj "/C=US/ST=NY/O=ASAPP, Inc./CN=mytestdomain.com" \
    -reqexts SAN \
    -config <(cat /etc/ssl/openssl.cnf \
        <(printf "\n[SAN]\nsubjectAltName=DNS:*.local,DNS:*.dc")) \
    -out mydomain.com.csr


# openssl req -new -config cert.conf -subj "CN=mytestdomain.com" -keyout mydomain.com.key -out mydomain.com.csr

openssl req -in mydomain.com.csr -noout -text

openssl x509 -req -in mydomain.com.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out mydomain.com.crt -days 500 -sha256

openssl x509 -in mydomain.com.crt -text -noout