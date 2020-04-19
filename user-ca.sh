# ===== create user certificate =====
mypass=123456
user=warodom.w

openssl genrsa -aes256 \
	  -passout pass:$mypass \
      -out intermediate/private/$user.key.pem 2048

chmod 400 intermediate/private/$user.key.pem


openssl req -config intermediate/openssl.cnf \
	  -passin pass:$mypass \
	  -passout pass:$mypass \
      -key intermediate/private/$user.key.pem \
      -new -sha256 -out intermediate/csr/$user.csr.pem \
	  -subj "/C=TH/postalCode=83120/ST=Phuket/L=Kathu/O=PSU/OU=Certificate Department/CN=$user/emailAddress=$user@psu.ac.th"

openssl ca -batch -config intermediate/openssl.cnf \
	  -passin pass:$mypass \
      -extensions usr_cert -days 365 -notext -md sha256 \
      -in intermediate/csr/$user.csr.pem \
      -out intermediate/certs/$user.cert.pem

chmod 444 intermediate/certs/$user.cert.pem

openssl x509 -noout -text \
      -in intermediate/certs/$user.cert.pem

openssl verify -CAfile intermediate/certs/ca-chain.cert.pem \
      intermediate/certs/$user.cert.pem

# =====  Convert to .p12 ====
openssl pkcs12 -export \
	-passin pass:$mypass \
	-passout pass:$mypass \
	-out intermediate/certs/$user.cert.p12 \
	-inkey intermediate/private/$user.key.pem \
	-in intermediate/certs/$user.cert.pem \
	-certfile intermediate/certs/ca-chain.cert.pem 

cp intermediate/certs/$user.cert.p12 ./output
