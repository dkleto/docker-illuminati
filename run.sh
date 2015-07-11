#! /bin/bash

dockreg="adamr:5000"
webimage="enlight-web"
webcont="enlight_web"
sitedir="/var/www/illuminati"
site_url="illuminati.local"

declare -A hostcookery
hostcookery=(
    ["$site_url"]="$webcont"
)

## Sync time across all containers with the host system
commontime=" -v /etc/localtime:/etc/localtime:ro "

## Check that the containers aren't already running
running=0
for CONTAINER in $webcont
    do
        if `sudo docker ps | grep --quiet $CONTAINER`
            then
                running=1
                echo "$CONTAINER is already running."
        fi
    done
if [ $running = 1 ]
    then
        exit
fi

## Remove previous containers.
for CONTAINER in $webcont
    do
        if sudo docker ps -a | grep --quiet "$CONTAINER"
            then
                sudo docker rm $CONTAINER
        fi
    done

sudo docker run -d --name $webcont $commontime -v `pwd`/www:$sitedir -t -i $dockreg/$webimage /bin/bash


## Cook hosts files according to config
for COOK in "${!hostcookery[@]}"
    do
    web_ip=`sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${hostcookery[$COOK]}`
    ## We need to escape periods.
    site_url_esc=`echo $COOK | sed -e 's/\./\\\./g'`
    web_ip_esc=`echo $web_ip | sed -e 's/\./\\\./g'`

    ## If the URL is already present, change the IP. If not, add an entry for it.
    if grep --quiet $COOK /etc/hosts;  then
        regex="-i 's/^.*$site_url_esc.*$/$web_ip_esc $site_url_esc/' /etc/hosts"
        eval sudo sed "$regex"
    else
        echo "## ${hostcookery[$COOK]} container" | sudo tee -a /etc/hosts
        echo "$web_ip $COOK" | sudo tee -a /etc/hosts
    fi
    done