# FUSE Docker image

This project builds a Docker image for [JBoss Fuse](http://www.jboss.org/products/fuse/overview/).

## Usage

You can then run a Fuse server with the following command:

    docker run -it jboss/jboss-fuse-full bin/fuse

Note that the web console will not be accessible since we have not yet defined users that can log into it
and have not exposed the web console port on the docker host.

## Extending the image

First, create a `users.properties` file that contains your users, passwords, and roles.  For example:

    admin=admin,admin,manager,viewer,Operator, Maintainer, Deployer, Auditor, Administrator, SuperUser


Then create a Dockerfile with the following content:

    FROM jboss/jboss-fuse-full
    COPY users.properties /opt/${FUSE_HOME}/etc/
    

Then you can build a new Docker image using the following commnad:

    docker build --tag=jboss/jboss-fuse-full-admin .

Run your new image:

    docker run -it -p 8181:8181 jboss/jboss-fuse-full-admin

The administration console should be available at [http://localhost:8181/hawtio](http://localhost:8181/hawtio)

## Ports Opened by Fuse

You may need to map ports opened by the Fuse container to host ports if you need to access it's services.
Those ports are:

* 8181 - Web access (also hosts the Fuse admin console).
* 8101 - SSH Karaf console access

If you add the ``-p 8181:8181` to your `docker run` command, then you should be able to load [http://localhost:8181/hawtio](http://localhost:8181/hawtio) in your web browser to mange the Fuse server.

If you add the ``-p 8101:8101` to your `docker run` command, then you should be able to ssh into the Karaf container using a command similar to: `ssh admin@localhost -p 8101`

## Ports used by JBoss AMQ

* 61616 - AMQ Openwire port.
* 1883  - AMQ MQTT port.
* 5672  - AMQ AMQP port.
* 61613 - AMQ STOMP port.
* 61617 - AMQ Openwire over SSL port.
* 8883  - AMQ MQTT over SSL port.
* 5671  - AMQ AMQP over SSL port.
* 61614 - AMQ STOMP over SSL port.

## Image internals

This image extends the [`jboss/base-jdk:8`](https://github.com/JBoss-Dockerfiles/base-jdk/tree/jdk8) image which adds the OpenJDK distribution on top of the [`jboss/base`](https://github.com/JBoss-Dockerfiles/base) image. Please refer to the README.md for selected images for more info.

The server is run as the `jboss` user which has the uid/gid set to `1000`.

Fuse is installed in the `/opt/jboss-fuse-${FUSE_VERSION}` directory.

## Source

The source is [available on GitHub](https://github.com/stekodyne/jboss-fuse-docker).

## Issues

Please report any issues or file RFEs on [GitHub](https://github.com/stekodyne/jboss-fuse-docker).