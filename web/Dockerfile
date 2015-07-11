FROM ubuntu:latest
MAINTAINER adamr <adamr@catalyst-au.net>


RUN apt-get update &&\
    apt-get install -yf git curl gcc make

RUN git clone https://github.com/postmodern/ruby-install.git /tmp/ruby-install &&\
    cd /tmp/ruby-install/ &&\
    make install &&\
    ruby-install ruby

ENV PATH=$PATH:/opt/rubies/ruby-2.2.2/bin

## Prevent reverse DNS lookup because it introduces serious latency.
RUN sed -i "s/\(:DoNotReverseLookup\s*=>\s*\)nil/\1true/" /opt/rubies/ruby-2.2.2/lib/ruby/2.2.0/webrick/config.rb

RUN gem install grape rack bundler
EXPOSE 80
CMD ["rackup", "/var/www/illuminati/config.ru"]
