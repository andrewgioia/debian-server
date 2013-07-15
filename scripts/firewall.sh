#!/bin/bash

# copy firewall over
#

echo 'This script will overwrite your firewall script'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    exit
fi

# if it exists, copy it over
#
if [ -f $basepath/conf/$profile/firewall.sh ] ; then
    cp $basepath/conf/$profile/firewall.sh /etc/firewall.sh
    chmod +x /etc/firewall.sh
fi

# alert the user to add the pre-up rule to /etc/network/interfaces
#
echo ''
echo 'IMPORTANT'
echo '---------'
echo 'ADD THE FOLLOWING LINE BEFORE THE ADDRESS LINE AFTER iface eth0 inet static:'
echo '    pre-up  /bin/sh /etc/firewall.sh'
echo ''