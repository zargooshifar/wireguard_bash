mkdir /etc/wireguard
cd /etc/wireguard
umask 077
wg genkey | tee "server_priv" | wg pubkey > "server_pub"


priv=$(<server_priv)
echo 1 > accounts


echo "[Interface]" > wg0.conf
echo "Address = 10.1.1.1/24" >> wg0.conf
echo "#SaveConfig = true" >> wg0.conf
echo "PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE" >> wg0.conf
echo "PostUp = iptables -t nat -I PREROUTING -i eth0 -p udp -m multiport --dports 53,80,4444,11,51,123,443 -j REDIRECT --to-ports 51820" >> wg0.conf
echo "ListenPort = 51820" >> wg0.conf
echo "PrivateKey = ${priv}" >> wg0.conf
echo "" >> wg0.conf

echo "net.ipv4.ip_forward=1" >>  /etc/sysctl.conf

systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service


ufw allow 51820/udp


reboot
