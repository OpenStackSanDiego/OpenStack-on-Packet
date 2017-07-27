

source ~/keystonerc_admin

for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39;
do

PROJECT=project$i
USER=user$i

echo $PROJECT $USER

openstack project create $PROJECT

openstack user create --password "openstack" $USER

openstack role create $USER

openstack role add --project $PROJECT --user $USER $USER

done
