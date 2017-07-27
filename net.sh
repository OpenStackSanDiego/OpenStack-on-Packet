# moves networking from the bond0 interface to the br-ex interface
# be careful, this may disconnect your SSH connection - run as a script not one line at a time

GATEWAY=`ip route list | egrep "^default" | cut -d' ' -f 3`
IP=`hostname -I | cut -d' ' -f 1`
SUBNET=`ip -4 -o addr show dev bond0 | grep $IP | cut -d ' ' -f 7`

ip route del default via $GATEWAY dev bond0
ip addr del $SUBNET dev bond0
ip addr add $SUBNET dev br-ex
ifconfig br-ex up
ovs-vsctl add-port br-ex bond0
ip route add default via $GATEWAY dev br-ex
