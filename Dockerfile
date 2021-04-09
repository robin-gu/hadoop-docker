FROM openjdk:8-jdk-buster

####################
# HADOOP
####################

ENV HADOOP_VERSION	3.2.2
ENV HIVE_VERSION	3.1.2

ENV HADOOP_HOME=/opt/hadoop-$HADOOP_VERSION
ENV HIVE_HOME=/opt/apache-hive-$HIVE_VERSION-bin

ENV HADOOP_OPTS		-Djava.library.path=/opt/hadoop/lib/native
ENV PATH		$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

WORKDIR /opt

RUN apt-get update && \
    apt-get -qqy install curl wget && \
    curl -L https://www-us.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz | tar zxf - && \
    curl -L https://www-us.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz | tar zxf - && \
    apt-get install --only-upgrade openssl libssl1.1 && \
    apt-get install -y libk5crypto3 libkrb5-3 libsqlite3-0 && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/tencentyun/hadoop-cos/releases/download/v5.9.3/hadoop-cos-3.1.0-5.9.3.jar -O $HADOOP_HOME/share/hadoop/tools/lib/hadoop-cos-3.1.0-5.9.3.jar && \
    wget https://github.com/tencentyun/hadoop-cos/releases/download/v5.9.3/cos_api-bundle-5.6.35.jar -O $HADOOP_HOME/share/hadoop/tools/lib/cos_api-bundle-5.6.35.jar && \
    wget https://jdbc.postgresql.org/download/postgresql-42.2.19.jar -O $HIVE_HOME/lib/postgresql-jdbc.jar 

# Overwrite default HADOOP configuration files with our config files
COPY conf  $HADOOP_HOME/etc/hadoop/

####################
# PORTS
####################
#
# http://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.3.0/bk_HDP_Reference_Guide/content/reference_chap2.html
# http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_ports_cdh5.html
# http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/core-default.xml
# http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/hdfs-default.xml

# HDFS: NameNode (NN):
#	 8020 = fs.defaultFS			(IPC / File system metadata operations)
#						(9000 is also frequently used alternatively)
#	 8022 = dfs.namenode.servicerpc-address	(optional port used by HDFS daemons to avoid sharing RPC port)
#       50070 = dfs.namenode.http-address	(HTTP  / NN Web UI)
#	50470 = dfs.namenode.https-address	(HTTPS / Secure UI)
# HDFS: DataNode (DN):
#	50010 = dfs.datanode.address		(Data transfer)
#	50020 = dfs.datanode.ipc.address	(IPC / metadata operations)
#	50075 = dfs.datanode.http.address	(HTTP  / DN Web UI)
#	50475 = dfs.datanode.https.address	(HTTPS / Secure UI)
# HDFS: Secondary NameNode (SNN)
#	50090 = dfs.secondary.http.address	(HTTP / Checkpoint for NameNode metadata)
EXPOSE 8020 8022 9000 50070 50010 50020 50075 50090

CMD ["sh"]
