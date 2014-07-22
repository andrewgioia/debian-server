#!/bin/bash
#
# Installs PHP from the dotdeb repository
##

echo 'This script will install PHP and PHP-FPM.'
read -p 'Do you want to continue [y/N]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit 0
fi

if ! [[ -f "/etc/apt/sources.list.d/dotdeb.list" ]] ; then
    echo '  --> adding dotdeb source and fetching key'
    echo 'deb http://packages.dotdeb.org stable all' > /etc/apt/sources.list.d/dotdeb.list
    echo 'deb-src http://packages.dotdeb.org stable all' >> /etc/apt/sources.list.d/dotdeb.list
    cd /opt
    wget http://www.dotdeb.org/dotdeb.gpg
    cat dotdeb.gpg | sudo apt-key add -
    rm dotdeb.gpg
    apt-get update
fi

echo '  --> installing php5 with FPM'
apt-get install \
    php5 php5-common php5-dev php5-curl \
    php5-mcrypt php5-mysql php5-pspell \
    php5-tidy php-pear libssh2-php \
    php5-cli php5-fpm

echo '  --> configuring php-fpm'

## Re-source the config file
. $basepath/conf/$profile/config

## Loop through any FPM domains and generate the pool.d
## conf file. We need to re-source the config file to
## get the array data.
for fpm_site in "${fpm_sites[@]}"
do
    ## Generate nginx site config files to sites-available
    ## and add symbolic links in sites-enabled
    if [[ -f "$basepath/conf/$profile/fpm/$fpm_site.conf" ]] ; then
        cp $basepath/conf/$profile/fpm/$fpm_site.conf /etc/php5/fpm/pool.d/$fpm_site.conf
    else
        if ! [[ -f "/etc/php5/fpm/pool.d/$fpm_site.conf" ]] ; then
            $basepath/src/fpm_example.sh $fpm_site
        fi
    fi
done

## Ask to add FPM to startup
read -p 'Do you want to add php-fpm to the startup? [y/N] ' wish
if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    update-rc.d php5-fpm defaults
fi

echo 'PHP and FPM completed'
echo ''