yum -y update
yum install -y https://www.rdoproject.org/repos/rdo-release.rpm
yum install -y openstack-packstack
yum -y update

time packstack --allinone \
	--os-cinder-install=n \
	--nagios-install=n 	\
	--os-ceilometer-install=n \
	--os-neutron-ml2-type-drivers=flat,vxlan \
	--os-heat-install=y \
  --os-magnum-install=y
  
yum install -y openstack-magnum-ui

# fix for https://bugs.launchpad.net/horizon/+bug/1671084 (heat topology tab not present in horizon)
sed -i 's/resources:index/resource:index/g' /usr/share/openstack-dashboard/openstack_dashboard/dashboards/project/stacks/tabs.py

# end of OpenStack cloud install

# OpenStack cloud configuration starts here...

. ~/keystonerc_admin

# delete the demo public subnet
OLD_SUBNET_ID=`openstack subnet show public_subnet -f value -c id`
ROUTER_ID=`openstack router show router1 -c id -f value`
# is there an openstack cli replacement for router gateway clear?
neutron router-gateway-clear $ROUTER_ID
openstack subnet delete $OLD_SUBNET_ID

# add the new public subnet

IP=`hostname -I | cut -d' ' -f 1`
SUBNET=`ip -4 -o addr show dev bond0 | grep $IP | cut -d ' ' -f 7`
DNS_NAMESERVER=`grep -i nameserver /etc/resolv.conf | head -n1 | cut -d ' ' -f2`

openstack subnet create                         \
        --network public                        \
        --dns-nameserver $DNS_NAMESERVER        \
        --subnet-range $SUBNET                  \
        $SUBNET

SUBNET_ID=`openstack subnet show $SUBNET -c id -f value`
neutron router-gateway-set router1 public

# create an internal network
INTERNAL_SUBNET=192.168.10.0/24

openstack network create internal

openstack subnet create                         \
        --network internal                      \
        --dns-nameserver $DNS_NAMESERVER        \
        --subnet-range $INTERNAL_SUBNET         \
        $INTERNAL_SUBNET

ROUTER_ID=`openstack router show router1 -c id -f value`
INTERNAL_SUBNET_ID=`openstack subnet show $INTERNAL_SUBNET -c id -f value`
openstack router add subnet $ROUTER_ID $INTERNAL_SUBNET_ID


# install some OS images
IMG_URL=https://download.fedoraproject.org/pub/alt/atomic/stable/Fedora-Atomic-25-20170626.0/CloudImages/x86_64/images/Fedora-Atomic-25-20170626.0.x86_64.qcow2
IMG_NAME=Fedora-Atomic-25
OS_DISTRO=fedora-atomic
wget -q -O - $IMG_URL | \
glance  --os-image-api-version 2 image-create --protected True --name $IMG_NAME \
        --visibility public --disk-format raw --container-format bare --property os_distro=$OS_DISTRO --progress
        
IMG_URL=https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2
IMG_NAME=CentOS-7
OS_DISTRO=centos
wget -q -O - $IMG_URL | \
glance  --os-image-api-version 2 image-create --protected True --name $IMG_NAME \
        --visibility public --disk-format raw --container-format bare --property os_distro=$OS_DISTRO --progress

wget https://stable.release.core-os.net/amd64-usr/current/coreos_production_openstack_image.img.bz2
bunzip2 coreos_production_openstack_image.img.bz2
IMG_URL=coreos_production_openstack_image.img
IMG_NAME=Container-Linux
OS_DISTRO=coreos
wget -q -O - $IMG_URL | \
glance  --os-image-api-version 2 image-create --protected True --name $IMG_NAME \
        --visibility public --disk-format raw --container-format bare --property os_distro=$OS_DISTRO --progress
        
IMG_URL=http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img
IMG_NAME=CirrOS-0.3.5
OS_DISTRO=cirros
wget -q -O - $IMG_URL | \
glance  --os-image-api-version 2 image-create --protected True --name $IMG_NAME \
        --visibility public --disk-format raw --container-format bare --property os_distro=$OS_DISTRO --progress    
	
IMG_URL=http://shell.openstack.us/Images/IoT.img
IMG_NAME=IoT
OS_DISTRO=centos
wget -q -O - $IMG_URL | \
glance  --os-image-api-version 2 image-create --protected True --name $IMG_NAME \
        --visibility public --disk-format raw --container-format bare --property os_distro=$OS_DISTRO --progress	
	
	
GATEWAY=`ip route list | egrep "^default" | cut -d' ' -f 3`
IP=`hostname -I | cut -d' ' -f 1`
SUBNET=`ip -4 -o addr show dev bond0 | grep $IP | cut -d ' ' -f 7`

ip route del default via $GATEWAY dev bond0
ip addr del $SUBNET dev bond0
ip addr add $SUBNET dev br-ex
ifconfig br-ex up
ovs-vsctl add-port br-ex bond0
ip route add default via $GATEWAY dev br-ex
	


  

