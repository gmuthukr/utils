#!/bin/bash -x
PUB_IN=$1
PUB_PO=$2
PRI_IP=$3
PRI_PO=$4
USAGE="$0 <public_interface> <public_port> <privarte_ip> <private_port>"

if [ "$#" != "4" ]; then
  echo $USAGE
  exit 1
fi

ret=`cat /proc/sys/net/ipv4/ip_forward`
if [ "$ret" != "1" ]; then
  echo 1 > /proc/sys/net/ipv4/ip_forward
  echo "ip_forward enabled"
fi

echo "#!/bin/bash" > cleanupnat.sh
iptables -t filter -I FORWARD -o management -d $PRI_IP -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
echo "iptables -t filter -D FORWARD -o management -d $PRI_IP -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT" >> cleanupnat.sh

iptables -t nat -A PREROUTING -i $PUB_IN -p tcp --dport $PUB_PO -j DNAT --to $PRI_IP:$PRI_PO
echo "iptables -t nat -D PREROUTING -i $PUB_IN -p tcp --dport $PUB_PO -j DNAT --to $PRI_IP:$PRI_PO" >> cleanupnat.sh

iptables -t nat -A POSTROUTING -p tcp -d $PRI_IP --dport $PRI_PO -j MASQUERADE
echo "iptables -t nat -D POSTROUTING -p tcp -d $PRI_IP --dport $PRI_PO -j MASQUERADE" >> cleanupnat.sh
