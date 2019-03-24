FROM centos:7
MAINTAINER gyd (fakeguoyd@gmail.com)
ADD jdk-8u144-linux-x64.tar.gz /usr/local/
ADD spark-2.2.0-bin-hadoop2.7.tgz /usr/local
ADD zookeeper-3.4.13.tar.gz /usr/local
RUN mkdir -p /usr/local/zookeeper-3.4.13/data \
 && touch /usr/local/zookeeper-3.4.13/data/myid \
 && mkdir -p /usr/local/zookeeper-3.4.13/datalog \
 && cp /usr/local/zookeeper-3.4.13/conf/zoo_sample.cfg /usr/local/zookeeper-3.4.13/conf/zoo.cfg \
 && echo "dataDir=/usr/local/zookeeper-3.4.13/data" >> /usr/local/zookeeper-3.4.13/conf/zoo.cfg \
 && echo "dataLogDir=/usr/local/zookeeper-3.4.13/datalog" >> /usr/local/zookeeper-3.4.13/conf/zoo.cfg \
 && mkdir -p /nfs/mnt 
ENV PATH=/usr/local/spark-2.2.0-bin-hadoop2.7/bin:/usr/local/spark-2.2.0-bin-hadoop2.7/sbin:$PATH \
    SPARK_MASTER_PORT=7077 \
    SPAKR_MASTER_WEBUI_PORT=13300 \
    SPARK_WORKER_PORT=7078 \
    SPARK_WORKER_WEBUI_PORT=8088 \
    SPARK_HOME=/usr/local/spark-2.2.0-bin-hadoop2.7 \
    ZOOKEEPER_DIR=/usr/local/zookeeper-3.4.13 \
    JAVA_HOME=/usr/local/jdk1.8.0_144\
    CLASSPATH=$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar \
    PATH=$PATH:$JAVA_HOME/bin
WORKDIR /usr/local/spark-2.2.0-bin-hadoop2.7
COPY entrypoint.sh /usr/local/spark-2.2.0-bin-hadoop2.7
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/usr/local/spark-2.2.0-bin-hadoop2.7/entrypoint.sh"]
CMD ["master"]


