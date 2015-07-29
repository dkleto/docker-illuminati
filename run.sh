#! /bin/bash

dockreg="adamr:5000"
webimage="enlight-web"
webcont="enlight_web"
mongoimage="enlight-mongo"
mongocont="enlight_mongo"
sitedir="/var/www/illuminati"

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
    ;;
    *)
    sudo docker run -d --name $mongocont $commontime -v `pwd`/mongodata:/data/db -t $dockreg/$mongoimage --noprealloc
    sudo docker run -d --name $webcont $commontime -p 80:9292 --link $mongocont:$mongocont -v `pwd`/www:$sitedir -t $dockreg/$webimage
esac
