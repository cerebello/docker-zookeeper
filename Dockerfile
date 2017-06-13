FROM debian:jessie
MAINTAINER Robson Júnior <bsao@cerebello.co> (@bsao)

##########################################
### ARGS AND ENVS
##########################################
ARG JAVA_MAJOR_VERSION=8
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
RUN groupadd --gid=${ZK_GID} ${ZK_GROUP}
RUN useradd --uid=${ZK_UID} --gid=${ZK_GID} --no-create-home ${ZK_USER}

##########################################
### DIRECTORIES
##########################################
RUN mkdir -p ${ZK_HOME}
RUN mkdir -p ${ZK_DATA_DIR}

##########################################
### UPDATE DIST AND INSTALL DEPENDENCIES
### INSTALL JAVA
##########################################
RUN \
  echo oracle-java${JAVA_MAJOR_VERSION}-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | \
    tee /etc/apt/sources.list.d/webupd8team-java.list && \
  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | \
    tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y oracle-java${JAVA_MAJOR_VERSION}-installer oracle-java${JAVA_MAJOR_VERSION}-set-default wget bash dnsutils sudo && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk${JAVA_MAJOR_VERSION}-installer
ENV JAVA_HOME /usr/lib/jvm/java-${JAVA_MAJOR_VERSION}-oracle

##########################################
### DOWNLOAD AND INSTALL ZOOKEEPER
##########################################
RUN wget ${ZK_MIRROR}/zookeeper-${ZK_VERSION}.tar.gz \
  && tar -xvf zookeeper-${ZK_VERSION}.tar.gz -C ${ZK_HOME} --strip=1 \
  && rm -rf zookeeper-${ZK_VERSION}.tar.gz
RUN chown -R ${ZK_USER}:${ZK_GROUP} ${ZK_DATA_DIR}
RUN chown -R ${ZK_USER}:${ZK_GROUP} ${ZK_HOME}
RUN chmod -R g+rwx ${ZK_DATA_DIR}
RUN chmod -R g+rwx ${ZK_HOME}

##########################################
### START SCRIPT
##########################################
ADD ./start.sh /opt/start-zookeeper.sh
RUN chmod +x /opt/start-zookeeper.sh

##########################################
### PORTS
##########################################
EXPOSE 2181
EXPOSE 2888
EXPOSE 3888

##########################################
### ENTRYPOINT
##########################################
USER ${ZK_USER}
WORKDIR ${ZK_HOME}
ENTRYPOINT ["/opt/start-zookeeper.sh"]
