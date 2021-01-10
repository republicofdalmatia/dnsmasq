FROM ubuntu:20.04
MAINTAINER republicofdalmatia

RUN apt-get update && apt-get install -y dnsmasq

EXPOSE 53

ENTRYPOINT ["/usr/sbin/dnsmasq","--keep-in-foreground","--log-facility=-","--user=root","--group=root"]
