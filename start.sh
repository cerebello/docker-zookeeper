#! /usr/bin/env bash

##########################################
### VALIDATE IP
### http://www.linuxjournal.com/content/validating-ip-address-bash-script
##########################################
function valid_ip()
{
    local  ip=$1
    local  stat=1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

##########################################
### CREATE zoo.cfg
##########################################
echo ${ZK_ID} > ${ZK_DATA_DIR}/myid
echo "tickTime=${ZK_TICK_TIME}" > ${ZK_HOME}/conf/zoo.cfg
echo "initLimit=${ZK_INIT_LIMIT}" >> ${ZK_HOME}/conf/zoo.cfg
echo "syncLimit=${ZK_SYNC_LIMIT}" >> ${ZK_HOME}/conf/zoo.cfg
echo "dataDir=${ZK_DATA_DIR}" >> ${ZK_HOME}/conf/zoo.cfg
echo "clientPort=2181" >> ${ZK_HOME}/conf/zoo.cfg
echo "maxClientCnxns=${ZK_CLIENT_CNXNS}" >> ${ZK_HOME}/conf/zoo.cfg
echo "autopurge.snapRetainCount=${ZK_AUTOPURGE_SNAP_RETAIN_COUNT}" >> ${ZK_HOME}/conf/zoo.cfg
echo "autopurge.purgeInterval=${ZK_AUTOPURGE_PURGE_INTERVAL}" >> ${ZK_HOME}/conf/zoo.cfg

for VAR in `env`
do
  if [[ $VAR =~ ^ZK_SERVER_[0-9]+= ]]; then
    IP=`echo "$VAR" | sed 's/.*=//'`
    SERVER_ID=`echo "$VAR" | sed -r "s/ZK_SERVER_(.*)=.*/\1/"`
    valid_ip ${IP}
    if [[ $? -eq 0 ]]; then
      SERVER_IP=${IP}
    else
      SERVER_IP=`dig +short $IP`
    fi
    if [ "${SERVER_ID}" = "${ZK_ID}" ]; then
      echo "server.${SERVER_ID}=0.0.0.0:2888:3888" >> ${ZK_HOME}/conf/zoo.cfg
    else
      echo "server.${SERVER_ID}=${SERVER_IP}:2888:3888" >> ${ZK_HOME}/conf/zoo.cfg
    fi
  fi
done

# show configurations
/bin/cat ${ZK_HOME}/conf/zoo.cfg

# start zookeeper
if [ "${ZK_DEAMON}" = "0" ]; then
    /bin/bash -c "${ZK_HOME}/bin/zkServer.sh start-foreground"
else
    /bin/bash -c "${ZK_HOME}/bin/zkServer.sh start"
fi