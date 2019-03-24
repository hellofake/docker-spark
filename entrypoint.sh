#!/bin/bash
SPARK_HOME=/usr/local/spark-2.2.0-bin-hadoop2.7
ZOOKEEPER_DIR=/usr/local/zookeeper-3.4.13
echo "spark.deploy.recoveryMode  ZOOKEEPER" >> ${SPARK_HOME}/conf/spark-defaults.conf
echo "spark.deploy.zookeeper.dir  ${ZOOKEEPER_DIR}/data" >> ${SPARK_HOME}/conf/spark-defaults.conf
echo "spark.deploy.zookeeper.url  ${SPARK_ZOOKEEPER_URL}" >> ${SPARK_HOME}/conf/spark-defaults.conf
echo "spark.worker.cleanup.enabled  true" >> ${SPARK_HOME}/conf/spark-defaults.conf
echo "spark.worker.cleanup.interval  ${SPARK_CHECK_INTERVAL}" >> ${SPARK_HOME}/conf/spark-defaults.conf
echo "spark.worker.cleanup.appDataTtl  ${SPARK_CLEAN_TIMEOUT" >> ${SPARK_HOME}/conf/spark-defaults.conf
array=(${ZOO_IP_IDS//,/ })
zoo_server="false"
for var in ${array[@]}
do
    ip_id=(${var//:/ })
    echo "server.${ip_id[1]}=${ip_id[0]}:2888:3888" >> ${ZOOKEEPER_DIR}/conf/zoo.cfg
    if [ ${CURRENT_IP} = ${ip_id[0]} ];then
       echo "${ip_id[1]}"  >> ${ZOOKEEPER_DIR}/data/myid
       zoo_server="true"
    fi
done
if [ ${zoo_server} = "true" ];then
  sh ${ZOOKEEPER_DIR}/bin/zkServer.sh start &
  echo "start zookeeper server"
else
  echo "don't start zookeeper server on this node"
fi
sleep 5
if [ "$1" = "master" ]; then
  sh ${SPARK_HOME}/sbin/start-master.sh -h ${CURRENT_IP} -p 7077 --webui-port 13300
  sleep 5
  sh ${SPARK_HOME}/sbin/start-slave.sh spark://$MASTER_ADDR --webui-port 13300
else
  sh ${SPARK_HOME}/sbin/start-slave.sh spark://$MASTER_ADDR --webui-port 13300
fi
echo "start end"
/bin/bash
