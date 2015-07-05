FROM ubuntu:latest
MAINTAINER adamr <adamr@catalyst-au.net>

RUN apt-get update &&\
    apt-get install -yf git curl wget gcc make

RUN git clone https://github.com/postmodern/ruby-install.git /tmp/ruby-install &&\
    cd /tmp/ruby-install/ &&\
    make install &&\
    ruby-install ruby
