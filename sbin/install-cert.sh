#!/bin/sh

cert_file=$1

echo "Installing $cert_file ..."

cp "$cert_file" /usr/local/share/ca-certificates/

update-ca-certificates

echo "Done."

