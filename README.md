# docker-spark
This repository contains Dockerfile to build spark standalone cluster mode using docker,and has start_spark.sh script to configure and run  spark standalone cluster mode.

## 1. The distributed file system
Dockerfile script using nfs as distributed file system,so you should install nfs first,if you have four computers
```
192.168.6.168 master
192.168.6.167 slave1
192.168.6.172 slave2
192.168.6.173 slave3
```
### 1) install nfs server on master
```
yum -y install nfs-utils rpcbind
```
then start nfs server by
```
systemctl start nfs
```
configure /etc/exports as below, /home/nfs is nfs server mount destination folder, you can configure it according to you computer.
if /home/nfs not exist, you should mkdir it first by ```mkdir -p /home/nfs```
```
/home/nfs 192.168.6.0/24(rw,no_root_squash,no_all_squash,sync)
```
after save you configure you should run ```exportfs -r``` to take it effect 
### 2) install nfs client on slaves
```
yum -y install nfs-utils
```
then start nfs, and lookup master's nfs file system as below
```
showmount -e 192.168.6.168
```
and run ```mkdir -p /nfs/mnt ```to mount master's nfs dictionary
```
mount -t nfs 192.168.6.168:/home/nfs /nfs/mnt -o proto=tcp -o nolock
```
you should mount /nfs/mnt nfs dictionary on master and slaves
Now master and slaves have nfs dictionary(/nfs/mnt), this will used by spark.

## 2.JDK1.8 Spark-2.2.0 and Zookeeper3.4.13
Dockerfile using downloaded file to copy to docker image, so you should download [JDK1.8](https://download.oracle.com/otn/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.tar.gz),[Spark-2.2.0](http://archive.apache.org/dist/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz),[Zookeeper3.4.13](http://archive.apache.org/dist/zookeeper/zookeeper-3.4.13/zookeeper-3.4.13.tar.gz) in the same directory with Dockerfile. Also, you can download other version spark、zookeeper、jdk, just rewrite Dockerfile.
## 3.start_spark.sh
This script has configuration as below.
```
SPARK_ZOOKEEPER_URL=192.168.6.168:2181,192.168.6.167:2181,192.168.6.172:2181 ##Zookeeper address
ZOO_IP_IDS=192.168.6.168:1,192.168.6.167:2,192.168.6.172:3 ## Zookeeper id configure
CURRENT_IP=192.168.6.167  ## current computes's ip address
MASTER_ADDR=192.168.6.168:7077,192.168.6.167:7077,192.168.6.172:7077 ## spark standalone master address, using zookeeper to guarantee HA
SPARK_LOGS_MNT_PATH=/home/docker/spark_logs ## spark logs, persistent stores
SPARK_WORK_HOME=/home/docker/spark_work ## spark work dir, every application will copy jar and other file to work dir, mount host dir to container to avoid no space in docker container error
SPARK_CHECK_INTERVAL=600 ## spark app clean check interval
SPARK_CLEAN_TIMEOUT=3600 ## spark app clean timeout
MASTER_OR_SLAVE=master ## this node is master or slave
NFS_MNT=/nfs/mnt ## nfs file system dir
```
you can configure time zone to replace TZ=Asia/Shanghai to make sure the time in docker is the same as host.
## 4.configure 、build and start
On every node, configure start_spark.sh(mainly CURRENT_IP,MASTER_OR_SLAVE, others configure are the same). On master, build images by
```
docker build -t link2map/spark:1.0 .
```
then save the image as tar and transfer to other node
```
docker save -o spark.tar link2map/spark:1.0
scp spark.tart user@slave1:/home/docker/spark
```
on slaves 
```
docker load < spark.tar
```
then, on all node run start_spark.sh to start spark standalone cluster 
```
sh start_spark.sh
```
now spark web-ui will start on MASTER:13300, zookeeper will select a random node as master(in this conf, it could be one of the three 192.168.6.168,192.168.6.167,192.168.6.172), at last you can submit application by [spark restful api](https://gist.github.com/arturmkrtchyan/5d8559b2911ac951d34a)
