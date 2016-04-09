FROM java:8-jre-alpine
MAINTAINER Elisey Zanko <elisey.zanko@gmail.com>

# Install required packages
RUN apk add --no-cache \
    bash=4.3.42-r3 \
    python=2.7.11-r3

# Download and install Apache Storm
RUN wget -q -O - http://apache-mirror.rbc.ru/pub/apache/storm/apache-storm-0.10.0/apache-storm-0.10.0.tar.gz | tar xzf -

WORKDIR apache-storm-0.10.0
ENTRYPOINT ["bin/storm"]