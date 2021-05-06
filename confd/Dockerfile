FROM ubuntu:18.04
MAINTAINER Appollo Systems

# confd file es downloaded on install.sh script
ADD confd /usr/local/bin/confd
RUN chmod +x /usr/local/bin/confd

CMD ["/usr/local/bin/confd", "-onetime", "-backend", "env"]
