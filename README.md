# About:

[Docker](http://www.docker.com/) image based on [openjdk:8-jre-alpine](https://hub.docker.com/_/openjdk/)

[![Docker Stars](https://img.shields.io/docker/stars/cerebello/zookeeper.svg)](https://hub.docker.com/r/cerebello/zookeeper/) [![Docker Pulls](https://img.shields.io/docker/pulls/cerebello/zookeeper.svg)](https://hub.docker.com/r/cerebello/zookeeper/) [![](https://images.microbadger.com/badges/image/cerebello/zookeeper.svg)](https://microbadger.com/images/cerebello/zookeeper)

## General Configuration:

| Variables | Property | Description | Default |
| --------- | -------- | ----------- | --------|
| ZK_ID | - | The id of the node. This must be set to a unique integer for each node. | 1 |
| ZK_TICK_TIME | tickTime | The length of a single tick, which is the basic time unit used by ZooKeeper | 2000 |
| ZK_INIT_LIMIT | initLimit | Amount of time, in ticks (see tickTime), to allow followers to connect and sync to a leader | 10 |
| ZK_SYNC_LIMIT | syncLimit | The entry syncLimit limits how far out of date a server can be from a leader | 20 |
| ZK_CLIENT_CNXNS | maxClientCnxns | Limits the number of concurrent connections (at the socket level) | 60 |
| ZK_AUTOPURGE_SNAP_RETAIN_COUNT | Retains the most recent snapshots and the corresponding transaction logs in the dataDir and dataLogDir | 3 |
| ZK_AUTOPURGE_PURGE_INTERVAL | autopurge.purgeInterval | The time interval in hours for which the purge task has to be triggered | 0 |
| ZK_DATA_DIR | dataDir | Zookeeper data dir | /var/zookeeper |
| ZK_DEAMON | - | execute as a deamon - 0=no / 1=yes | 0 |

## Running Mode:

```
$ docker run -p 2181:2181 -p 2888:2888 -p 3888:3888 cerebello/zookeeper:3.4.10
```