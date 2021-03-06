# Self-Signed Cert Gen Scripts

A collection of scripts used to generate self-signed certificates.

There are two scripts - one to create the root certificate, this cert is generated by executing:

```
    ./make_ca.sh
```

this supports a couple of environment variables:

**COMMON_NAME** -> this is the common name for the cert, defaults to the machine's hostname

**ORGANIZATION** -> The organization owning the cert (defaults to ASAPP)

**ORGANIZATION_UNIT** -> The organization unit of the cert (defaults to Platform)

The resulting CA cert will be output in to the local directory with the name rootCA.crt and rootCA.key.


To then generate a cert for a service execute:

```
    ./make_cert.sh
```

this supports a couple of environment variables:

**COMMON_NAME** -> this is the common name for the cert, defaults to the machine's hostname

**ORGANIZATION** -> The organization owning the cert (defaults to ASAPP)

**ORGANIZATION_UNIT** -> The organization unit of the cert (defaults to Platform)

**SAN** -> the set of alternate names to define in the cert. This should be of the form: *DNS:\*.local,DNS:\*.asapp.com,DNS:\*.blah*

In addition this scripts requires 3 command line args:

root_ca.crt-file root_ca.key-file output_file_root

so an example of executing this would be:

```
    ./make_cert rootCA.crt rootCA.key mynewkey
```

this will produce:

* mynewkey.key
* mynewkey.csr
* mynewkey.pem