#!/bin/bash

# Adjust the following env vars if needed.
FUSE_ARTIFACT_ID=jboss-fuse-karaf

# Lets fail fast if any command in this script does succeed.
set -e

#
# Lets switch to the /opt dir
#
cd /opt

# Extract the distro
jar -xvf ${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip
rm ${FUSE_ARTIFACT_ID}-${FUSE_VERSION}.zip
chmod a+x ${FUSE_HOME}/bin/*

# Lets remove some bits of the distro which just add extra weight in a docker image.
rm -rf ${FUSE_HOME}/extras
rm -rf ${FUSE_HOME}/quickstarts

#
# Let the karaf container name/id come from setting the FUSE_KARAF_NAME && FUSE_RUNTIME_ID env vars
# default to using the container hostname.
sed -i -e 's/environment.prefix=FABRIC8_/environment.prefix=FUSE_/' ${FUSE_HOME}/etc/system.properties
sed -i -e '/karaf.name = root/d' ${FUSE_HOME}/etc/system.properties
sed -i -e '/runtime.id=/d' ${FUSE_HOME}/etc/system.properties
echo '
if [ -z "$FUSE_KARAF_NAME" ]; then 
  export FUSE_KARAF_NAME="$HOSTNAME"
fi
if [ -z "$FUSE_RUNTIME_ID" ]; then 
  export FUSE_RUNTIME_ID="$FUSE_KARAF_NAME"
fi

export KARAF_OPTS="-Dkaraf.name=${FUSE_KARAF_NAME} -Druntime.id=${FUSE_RUNTIME_ID}"
'>> ${FUSE_HOME}/bin/setenv

#
# Move the bundle cache and tmp directories outside of the data dir so it's not persisted between container runs
#
mv ${FUSE_HOME}/data/tmp ${FUSE_HOME}/tmp
echo '
org.osgi.framework.storage=${karaf.base}/tmp/cache
'>> ${FUSE_HOME}/etc/config.properties
sed -i -e 's/-Djava.io.tmpdir="$KARAF_DATA\/tmp"/-Djava.io.tmpdir="$KARAF_BASE\/tmp"/' ${FUSE_HOME}/bin/karaf
sed -i -e 's/-Djava.io.tmpdir="$KARAF_DATA\/tmp"/-Djava.io.tmpdir="$KARAF_BASE\/tmp"/' ${FUSE_HOME}/bin/fuse
sed -i -e 's/-Djava.io.tmpdir="$KARAF_DATA\/tmp"/-Djava.io.tmpdir="$KARAF_BASE\/tmp"/' ${FUSE_HOME}/bin/client
sed -i -e 's/-Djava.io.tmpdir="$KARAF_DATA\/tmp"/-Djava.io.tmpdir="$KARAF_BASE\/tmp"/' ${FUSE_HOME}/bin/admin
sed -i -e 's/${karaf.data}\/generated-bundles/${karaf.base}\/tmp\/generated-bundles/' ${FUSE_HOME}/etc/org.apache.felix.fileinstall-deploy.cfg

# lets remove the karaf.delay.console=true to disable the progress bar
sed -i -e 's/karaf.delay.console=true/karaf.delay.console=false/' ${FUSE_HOME}/etc/config.properties
echo '
# Root logger
log4j.rootLogger=INFO, stdout, osgi:*VmLogAppender
log4j.throwableRenderer=org.apache.log4j.OsgiThrowableRenderer

# CONSOLE appender not used by default
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=%d{ABSOLUTE} | %-5.5p | %-16.16t | %-32.32c{1} | %X{bundle.id} - %X{bundle.name} - %X{bundle.version} | %m%n
' > ${FUSE_HOME}/etc/org.ops4j.pax.logging.cfg

echo '
bind.address=0.0.0.0
'>> ${FUSE_HOME}/etc/system.properties
echo '' >> ${FUSE_HOME}/etc/users.properties

rm /opt/install.sh
