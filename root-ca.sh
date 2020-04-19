mypass=123456
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

# curl https://jamielinux.com/docs/openssl-certificate-authority/_downloads/root-config.txt > openssl.cnf

openssl genrsa -aes256 \
	-passout pass:$mypass \
	-out private/ca.key.pem 4096

chmod 400 private/ca.key.pem

openssl req -config openssl.cnf \
	  -passin pass:$mypass \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem \
      -subj '/C=TH/postalCode=83120/ST=Phuket/L=Kathu/O=PSU/OU=Certificate Department/CN=PSU Root CA/emailAddress=warodom.w@phuket.psu.ac.th'

openssl x509 -noout -text -in certs/ca.cert.pem   # verify

echo '==== Create root CA done ========'
