echo '===== Create intermediate pair ======='  # don't forget to change abs path in openssl.cnf
# mkdir /root/ca/intermediate
mypass=123456
mkdir intermediate
cd ./intermediate
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
cp ../openssl.cnf .
echo 1000 > ./crlnumber
# curl https://jamielinux.com/docs/openssl-certificate-authority/_downloads/intermediate-config.txt > openssl.cnf

# cd /root/ca
cd ../root

openssl genrsa -aes256 \
      -passout pass:$mypass \
      -out ../intermediate/private/intermediate.key.pem 4096
chmod 400 ../intermediate/private/intermediate.key.pem

openssl req -config ../intermediate/openssl.cnf -new -sha256 \
	-passin pass:$mypass \
      -key ../intermediate/private/intermediate.key.pem \
      -out ../intermediate/csr/intermediate.csr.pem \
	-subj '/C=TH/postalCode=83120/ST=Phuket/L=Kathu/O=PSU/OU=Certificate Department/CN=PSU intermediate CA/emailAddress=warodom.w@psu.ac.th'


openssl ca -batch -config openssl.cnf -extensions v3_intermediate_ca \
	-passin pass:$mypass \
      -days 3650 -notext -md sha256 \
      -in ../intermediate/csr/intermediate.csr.pem \
      -out ../intermediate/certs/intermediate.cert.pem

chmod 444 ../intermediate/certs/intermediate.cert.pem

openssl x509 -noout -text \
      -in ../intermediate/certs/intermediate.cert.pem

openssl verify -CAfile certs/ca.cert.pem \
      ../intermediate/certs/intermediate.cert.pem

# create certificate chain
cat ../intermediate/certs/intermediate.cert.pem \
      certs/ca.cert.pem > ../intermediate/certs/ca-chain.cert.pem

chmod 444 ../intermediate/certs/ca-chain.cert.pem
