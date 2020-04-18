# ===== create user certificate =====
mypass=123456
user=foobar3

mkdir $user

cd ./$user
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > ./crlnumber
# curl https://jamielinux.com/docs/openssl-certificate-authority/_downloads/intermediate-config.txt > openssl.cnf
# cd /root/ca
cd ../root

echo `pwd`

openssl genrsa -aes256 \
	  -passout pass:$mypass \
      -out ../$user/private/$user.key.pem 2048

chmod 400 ../$user/private/$user.key.pem


openssl req -config ../intermediate/openssl.cnf \
	  -passin pass:$mypass \
	  -passout pass:123456 \
      -key ../$user/private/$user.key.pem \
      -new -sha256 -out ../$user/csr/$user.csr.pem \
	  -subj "/C=TH/postalCode=83120/ST=Phuket/L=Kathu/O=PSU/OU=Certificate Department/CN=$user/emailAddress=$user@psu.ac.th"

openssl ca -batch -config ../intermediate/openssl.cnf \
	  -passin pass:$mypass \
      -extensions usr_cert -days 365 -notext -md sha256 \
      -in ../$user/csr/$user.csr.pem \
      -out ../$user/certs/$user.cert.pem

chmod 444 ../$user/certs/$user.cert.pem

openssl x509 -noout -text \
      -in ../$user/certs/$user.cert.pem

openssl verify -CAfile ../intermediate/certs/ca-chain.cert.pem \
      ../$user/certs/$user.cert.pem

# =====  Convert to .p12 ====
openssl pkcs12 -export \
	-passin pass:$mypass \
	-passout pass:$mypass \
	-out ../$user/certs/$user.cert.p12 \
	-inkey ../$user/private/$user.key.pem \
	-in ../$user/certs/$user.cert.pem \
	-certfile ../intermediate/certs/ca-chain.cert.pem 

cp ../$user/certs/$user.cert.p12 ../output
