#! /bin/bash

dockreg="adamr:5000"
webimage="enlight-web"
webcont="enlight_web"
mongoimage="enlight-mongo"
mongocont="enlight_mongo"
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
for CONTAINER in $webcont $mongocont
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
for CONTAINER in $webcont $mongocont
    do
        if sudo docker ps -a | grep --quiet "$CONTAINER"
            then
                sudo docker rm $CONTAINER
        fi
    done

case $1 in
    test)
sudo docker run -d --name $mongocont $commontime -v `pwd`/mongodata:/data/db -t $dockreg/$mongoimage
sudo docker run --name $webcont $commontime --link $mongocont:$mongocont -v `pwd`/www:$sitedir -t -i $dockreg/$webimage /opt/rubies/ruby-2.2.2/bin/rspec
sudo docker kill enlight_web enlight_mongo
    exit
sudo docker run -d --name $mongocont $commontime -v `pwd`/mongodata:/data/db -t $dockreg/$mongoimage --noprealloc
sudo docker run -d --name $webcont $commontime --link $mongocont:$mongocont -v `pwd`/www:$sitedir -t $dockreg/$webimage
    ;;
    *)
    continue
esac


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
