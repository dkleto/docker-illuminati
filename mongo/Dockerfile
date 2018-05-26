FROM mongo:latest
MAINTAINER adamr <adamr@catalyst-au.net>

VOLUME /data/db

EXPOSE 27017

CMD ["usr/bin/mongod", "--smallfiles", "--noprealloc", "--bind_ip_all"]
