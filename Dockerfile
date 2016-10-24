# Use latest jboss/base-jdk:8 image as the base
FROM jboss/base-jdk:8

MAINTAINER Steffen Kory <stekodyne@gmail.com>

# Set the FUSE_VERSION env variable
ENV FUSE_VERSION 6.3.0.redhat-187
ENV FUSE_HOME /opt/jboss-fuse-${FUSE_VERSION}

# If the container is launched with re-mapped ports, these ENV vars should
# be set to the remapped values.
ENV FUSE_PUBLIC_OPENWIRE_PORT 61616
ENV FUSE_PUBLIC_MQTT_PORT 1883
ENV FUSE_PUBLIC_AMQP_PORT 5672
ENV FUSE_PUBLIC_STOMP_PORT 61613
ENV FUSE_PUBLIC_OPENWIRE_SSL_PORT 61617
ENV FUSE_PUBLIC_MQTT_SSL_PORT 8883
ENV FUSE_PUBLIC_AMQP_SSL_PORT 5671
ENV FUSE_PUBLIC_STOMP_SSL_PORT 61614

# Copy the fuse zip to the image.
COPY jboss-fuse-karaf-${FUSE_VERSION}.zip /opt/jboss-fuse-karaf-${FUSE_VERSION}.zip

# Install fuse in the image.
COPY install.sh /opt/install.sh
RUN /opt/install.sh

# Copy users.properties to image.
COPY users.properties /opt/${FUSE_HOME}/etc/users.properties

EXPOSE 8181 8101 1099 44444 61616 1883 5672 61613 61617 8883 5671 61614

#
# The following directories can hold config/data, so lets suggest the user
# mount them as volumes.
VOLUME /opt/${FUSE_HOME}/bin
VOLUME /opt/${FUSE_HOME}/etc
VOLUME /opt/${FUSE_HOME}/data
VOLUME /opt/${FUSE_HOME}/deploy

# lets default to the jboss-fuse dir so folks can more easily navigate to around the server install
WORKDIR /opt/${FUSE_HOME}
CMD /opt/${FUSE_HOME}/bin/fuse server