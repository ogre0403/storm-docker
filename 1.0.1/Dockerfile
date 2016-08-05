FROM java:8-jre-alpine
MAINTAINER Jimmy Chuang <ogre0403@gmail.com>

# Install required packages
RUN apk add --no-cache \
    bash \
    python \ 
    py-pip

ENV STORM_USER=storm
ENV STORM_LOCAL_DIR=/data
ENV STORM_LOG_DIR=/logs
ENV STORM_HOME=/apache-storm-1.0.1

# Add a user and make dirs
RUN set -x \
    && adduser -D "$STORM_USER" \
    && mkdir -p "$STORM_LOCAL_DIR" "$STORM_LOG_DIR" \
    && chown -R "$STORM_USER:$STORM_USER" "$STORM_LOCAL_DIR" "$STORM_LOG_DIR"

RUN pip install supervisor

ENV DISTRO_NAME=apache-storm-1.0.1
# Download Apache Storm, verify its PGP signature, untar and clean up
RUN set -x \
    && apk add --no-cache --virtual .build-deps \
    && wget "http://apache.stu.edu.tw/storm/$DISTRO_NAME/$DISTRO_NAME.tar.gz" \
    && tar -xzf "$DISTRO_NAME.tar.gz" \
    && chown -R "$STORM_USER:$STORM_USER" "$DISTRO_NAME" \
    && rm -r "$DISTRO_NAME.tar.gz" \ 
    && apk del .build-deps

RUN mkdir /var/log/storm ; chown -R storm:storm /var/log/storm ; ln -s /var/log/storm /home/storm/log
RUN ln -s $STORM_HOME/bin/storm /usr/bin/storm
ADD conf/storm.yaml.template $STORM_HOME/conf/storm.yaml.template


# add default supervisord.conf
RUN mkdir -p /etc/supervisor/conf.d
ADD supervisor/supervisord.conf /etc/supervisor/supervisord.conf

# add storm-daemon template
ADD supervisor/storm-daemon.conf /home/storm/storm-daemon.conf


WORKDIR $DISTRO_NAME

ENV PATH $PATH:/$DISTRO_NAME/bin

ADD script/entrypoint.sh /home/storm/entrypoint.sh
ENTRYPOINT ["/bin/bash", "/home/storm/entrypoint.sh"]

