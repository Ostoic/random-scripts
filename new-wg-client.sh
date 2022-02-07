#!/bin/bash

if [ $# -ne 2 ]; then
  echo 'Usage: ./new-wg-client.sh laptop 10.0.0.4/32'
  echo 'Set the $WG_ENDPOINT environment variable to specify which WG server is in use'
  exit -1
fi

if [ $(id -u) -ne 0 ]; then
  echo 'Must be root to run this scripts'
  exit -2
fi

PROFILE_NAME=$1
ALLOWED_IPS=$2
IFACE='wg0'
PUBKEY=$(wg show $IFACE public-key)

wg genkey | tee /etc/wireguard/clients/$PROFILE_NAME.key | wg pubkey | tee /etc/wireguard/clients/$PROFILE_NAME.key.pub

template="[Interface]\n
PrivateKey = $(cat /etc/wireguard/clients/$PROFILE_NAME.key)\n
Address = $ALLOWED_IPS\n
\n
[Peer]\n
PublicKey = $PUBKEY\n
AllowedIPs = 0.0.0.0/0\n
Endpoint = $WG_ENDPOINT:11664\n
"

echo "Public Key: $(cat /etc/wireguard/clients/$PROFILE_NAME.key.pub)"
echo "Private Key: $(cat /etc/wireguard/clients/$PROFILE_NAME.key)"

echo -ne $template > /etc/wireguard/clients/$PROFILE_NAME.conf
qrencode -t ansiutf8 < /etc/wireguard/clients/$PROFILE_NAME.conf

new_peer="[Peer]\n
PublicKey= $(cat /etc/wireguard/clients/$PROFILE_NAME.key.pub)\n
AllowedIPs = $ALLOWED_IPS\n\n
"

echo -ne $new_peer | tee --append /etc/wireguard/$IFACE.conf
