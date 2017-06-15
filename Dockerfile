FROM openjdk:8-jre-alpine
MAINTAINER Robson Júnior <bsao@cerebello.co> (@bsao)

##########################################
### ARGS AND ENVS
##########################################
ARG ZK_MIRROR=http://artfiles.org/apache.org/zookeeper/stable
ARG ZK_VERSION=3.4.10
ENV ZK_VERSION=${ZK_VERSION}
ENV ZK_HOME=/opt/zookeeper
ENV ZK_DATA_DIR=/var/zookeeper
LABEL name="ZK" version=${ZK_VERSION}

##########################################
### REPLICATED ZOOKEEPER CONFIGRUATION
##########################################
# ID of the cluster
ENV ZK_ID=1
# The length of a single tick, which is the basic time unit used by ZooKeeper
ENV ZK_TICK_TIME=2000
# Amount of time, in ticks (see tickTime), to allow followers to connect and sync to a leader
ENV ZK_INIT_LIMIT=10
# The entry syncLimit limits how far out of date a server can be from a leader
ENV ZK_SYNC_LIMIT=20
# Limits the number of concurrent connections (at the socket level)
ENV ZK_CLIENT_CNXNS=60
# retains the most recent snapshots and the corresponding transaction logs in the dataDir and dataLogDir
ENV ZK_AUTOPURGE_SNAP_RETAIN_COUNT=3
# The time interval in hours for which the purge task has to be triggered
ENV ZK_AUTOPURGE_PURGE_INTERVAL=0
# execute as a deamon - 0=no / 1=yes
ENV ZK_DEAMON=0

##########################################
### CREATE USERS
##########################################
ARG ZK_USER=zookeeper
ARG ZK_GROUP=zookeeper
ARG ZK_UID=5000
ARG ZK_GID=5000
ENV ZK_USER=${ZK_USER}
ENV ZK_GROUP=${ZK_GROUP}
ARG ZK_UID=${ZK_UID}
ARG ZK_GID=${ZK_GID}
RUN addgroup -g ${ZK_GID} -S ${ZK_GROUP} && \
    adduser -u ${ZK_UID} -D -S -G ${ZK_USER} ${ZK_GROUP}

##########################################
### DIRECTORIES
##########################################
RUN mkdir -p ${ZK_HOME} && \
    mkdir -p ${ZK_DATA_DIR}

##########################################
### DNS UTILS
##########################################
RUN apk add --update --no-cache  \
    bash tar bind-tools shadow

##########################################
### DOWNLOAD AND INSTALL ZOOKEEPER
##########################################
RUN wget ${ZK_MIRROR}/zookeeper-${ZK_VERSION}.tar.gz && \
    tar -xvf zookeeper-${ZK_VERSION}.tar.gz -C ${ZK_HOME} --strip=1  && \
    rm -rf zookeeper-${ZK_VERSION}.tar.gz && \
    chown -R ${ZK_USER}:${ZK_GROUP} ${ZK_DATA_DIR} && \
    chown -R ${ZK_USER}:${ZK_GROUP} ${ZK_HOME} && \
    chmod -R g+rwx ${ZK_DATA_DIR} && \
    chmod -R g+rwx ${ZK_HOME}

##########################################
### START SCRIPT
##########################################
ADD ./start.sh /opt/start-zookeeper.sh
RUN chmod +x /opt/start-zookeeper.sh

##########################################
### PORTS
##########################################
EXPOSE 2181 2888 3888

##########################################
### ENTRYPOINT
##########################################
USER ${ZK_USER}
WORKDIR ${ZK_HOME}
ENTRYPOINT ["/opt/start-zookeeper.sh"]