#!/usr/bin/env bash

# Enter posix mode for bash
set -o posix
set -e

usage="Usage: entrypoint.sh [--daemon (nimbus|drpc|supervisor|ui|logviewer]"

if [ $# -lt 1 ]; then
 echo $usage >&2;
 exit 2;
fi

daemons=(nimbus, drpc, supervisor, ui, logviewer)

# Create supervisor configurations for Storm daemons
create_supervisor_conf () {
    echo "Create supervisord configuration for storm daemon $1"
    cat /home/storm/storm-daemon.conf | sed s,%daemon%,$1,g | tee -a /etc/supervisor/conf.d/storm-$1.conf
}

# Command

case $1 in
    --daemon)
        shift
        for daemon in $*; do
          create_supervisor_conf $daemon
        done
    ;;
    --all)
        for daemon in daemons; do
          create_supervisor_conf $daemon
        done
    ;;
    *)
        echo $usage
        exit 1;
    ;;
esac


# storm.yaml - replace zookeeper and nimbus ports with environment variables exposed by Docker container(see docker run --link name:alias)

function init_storm_yaml() {
    STORM_YAML=$STORM_HOME/conf/storm.yaml
    cp $STORM_HOME/conf/storm.yaml.template $STORM_YAML

    sed -i s/%zk_service_name%/$ZK_SERVICE_NAME/g $STORM_YAML
    sed -i s/%nimbus_service_name%/$NIMBUS_SERVICE_NAME/g $STORM_YAML
    sed -i s/%service_name%/$SERVICE_NAME/g $STORM_YAML

    for var in `( set -o posix ; set ) | grep CONFIG_`; do
        name=${var%"="*}
        confValue=${var#*"="}
        confName=`echo ${name#*CONFIG_} | awk '{print tolower($0)}'`
        confName=`echo $confName | sed -r 's/_/./g'`
        n=`echo $(grep -n "^${confName}:" "${STORM_YAML}" | cut -d : -f 1)`
        if [ ! -z "$n" ]; then
           echo "Override property $confName=$confValue (storm.yaml)"
           sed -i "${n}s|.*|$confName: $confValue|g" $STORM_YAML
        else
           echo "Add property $confName=$confValue (storm.yaml)"
           $(echo "$confName: $confValue" >> ${STORM_YAML})
        fi
    done
}

init_storm_yaml

supervisord

exit 0;
