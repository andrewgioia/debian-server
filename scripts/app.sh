#!/bin/bash

# set up the application, sites, and all
#

echo 'This script will create application directories, and overwrite any nginx config files for your sites'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit
fi

usage="$0 <config>"
config=${1:-"../conf/config"}

if [ ! -f $config ] ; then
    echo "Could not find the config file you entered: $config"
    exit
fi

. $config

# configure environment
#
echo '  --> configuring the environment directories'
if [ ! -d /var/www ] ; then
    mkdir /var/www
fi

# loop through any available sites and ssl sites
#
for site in "${sites[@]}"
do
    #if [ ! -d /var/www/$site ] ; then
    #    mkdir /var/www/$site
    #fi
    #if [ ! -d /var/www/$site/www-data ] ; then
    #    mkdir /var/www/$site/www-data
    #fi

    # generate nginx site config files to sites-available and add 
    # symbolic links in sites-enabled
    #
    $basepath/src/nginx_conf/example.com.conf.sh $site


    #cp $basepath/src/index.php /var/www/$site/www-data/index.php
done

exit;



for ssl_site in "${ssl_sites[@]}"
do
    if [ ! -d /var/www/$ssl_site ] ; then
        mkdir /var/www/$ssl_site
    fi
    if [ ! -d /var/www/$ssl_site/www-data ] ; then
        mkdir /var/www/$ssl_site/www-data
    fi

    # generate nginx site config files to sites-available
    #

    # add symbolic links in sites-enabled
    #

    cp $basepath/src/index.php /var/www/$site/www-data/index.php
done

# copy over remaining nginx files
#
cp $basepath/src/404.html /var/www/404.html
cp $basepath/src/50x.html /var/www/50x.html

# clone repos
#
echo '  --> install the app files'
apt-get install bc
mkdir /home/repos

# check for any mercurial projects (install if not installed)
#
if [ ${#hg} ]; then
    if ! [ hash hg 2>/dev/null ]; then
        apt-get install hg
    fi
    for hg_url in "${hg[@]}"
    do
        echo hg_url
    done
fi

# check for any git projects (install if not installed)
#
if [ ${#git} ]; then
    if ! [ hash git 2>/dev/null ]; then
        apt-get install git
    fi
    for git_url in "${git[@]}"
    do
        echo git_url
    done
fi

# update permissions
#
chown -R www-data:www-data /var/www
chown -R $username:$username /home/$username/repos

# remove apache (again)
#
/etc/init.d/apache2 stop
/usr/sbin/update-rc.d -f apache2 remove

# restart nginx
#
echo '  --> restarting nginx'
/etc/init.d/nginx restart
