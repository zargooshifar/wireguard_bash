echo "enter name (without space):"
read name
cd  /etc/wireguard/
umask 077
wg genkey | tee "${name}_priv" | wg pubkey > "${name}_pub"
echo

priv=$(<${name}_priv)
pub=$(<${name}_pub)
server_pub=$(<server_pub)

count=$(<accounts)
count=$((count + 1))
echo $count > accounts
ip="10.1.1.${count}"

sudo systemctl stop wg-quick@wg0


echo "# ${name}" >> wg0.conf
echo "[Peer]" >> wg0.conf
echo "PublicKey = ${pub}" >> wg0.conf
echo "AllowedIPs = ${ip}/32" >> wg0.conf
echo "" >> wg0.conf


echo "your configuration is:"
echo "replace server_ip with your server ip!"
echo "############"
echo "[Interface]"
echo "PrivateKey = ${priv}"
echo "Address = ${ip}/24"
echo "DNS = 8.8.8.8, 1.1.1.1"
echo
echo "[Peer]"
echo "PublicKey = ${server_pub}"
echo "AllowedIPs = 0.0.0.0/0"
echo "Endpoint = server_ip:51820"
echo "#Endpoint = server_ip:11"
echo "#Endpoint = server_ip:53"
echo "#Endpoint = server_ip:123"
echo "#Endpoint = server_ip:4444"
echo "#PersistentKeepalive = 15"
echo "############"
echo ""

sudo systemctl start wg-quick@wg0

sudo systemctl enable wg-quick@wg0
sudo systemctl restart wg-quick@wg0
