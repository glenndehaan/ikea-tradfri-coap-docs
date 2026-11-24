#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

git clone https://github.com/obgm/libcoap.git libcoap-openssl
cd libcoap-openssl
git submodule update --init --recursive
./configure CPPFLAGS="-DCOAP_OPENSSL_PSK_SECURITY_LEVEL=0" --with-openssl --enable-examples --disable-documentation --enable-shared
make -j$(nproc)
make install
ldconfig
