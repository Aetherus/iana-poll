#!/bin/sh

cert_file=$1

set -e

echo "Installing $cert_file ..."

cp "$cert_file" /usr/local/share/ca-certificates/

update-ca-certificates --fresh

echo "Done."
