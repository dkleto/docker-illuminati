FROM ubuntu:latest
MAINTAINER adamr <adamr@catalyst-au.net>


RUN apt-get update &&\
    apt-get install -yf git curl gcc make

RUN git clone https://github.com/postmodern/ruby-install.git /tmp/ruby-install &&\
    cd /tmp/ruby-install/ &&\
    make install &&\
    ruby-install ruby

ENV PATH=$PATH:/opt/rubies/ruby-2.2.2/bin

RUN gem install grape rack
EXPOSE 80
