#!/bin/bash

# THIS SCRIPT REQUIRES THE FOLLOWING PARAMETERS:
# COLLECTION CONIFIG NAME (TEXT)
# NUMBER OF SHARDS (NUMBER)
# JETTY PORT (NUMBER)
# SCHEMA FILE NAME (TEXT)
# JETTY SERVER COUNT (NUMBER)
# SOLRCONFIG FILE NAME (TEXT)
#
# EXAMPLE: ./startSolrCloud.sh MY1STDEMO 2 4500 schema.xml 2 solrconfig.xml

export COLLECTION_CONFIGNAME=$1;
export NUM_SHARDS=$2;
export JETTY_PORT=$3;
export SCHEMA=$4;
export JETTY_SERVER_COUNT=$5;
export CONFIG=$6;

export BASE="/Users/solr/Desktop/solr4.10.3";
export SOLR_HOME=${BASE}"/example";
export SOLR_HOST="localhost";
export CORE_PROPERTIES=${SOLR_HOME}"/cores";
export BOOTSTRAP_CONFDIR="/Users/solr/Desktop/conf";
export ZK_HOST="127.0.0.1:9181";

export DATA_DIR="/Users/solr/Desktop/data/${COLLECTION_CONFIGNAME}";
export SHARD_DIR_NAME="SHARD";
export LOGS_DIR="/Users/solr/Desktop/logs/${COLLECTION_CONFIGNAME}"
export LOG_DIR_NAME="SHARD_LOG";

export JETTY_STOP_PORT=$((JETTY_PORT+(NUM_SHARDS*JETTY_SERVER_COUNT)));
export JETTY_STOP_KEYWORD="STOP_JETTY";

export SOLR_JAVA_OPTS="-server -d64 -Xms1g -Xmx1g -Dsolr.solr.home=${SOLR_HOME} \
-DzkHost=${ZK_HOST} -Dhost=${SOLR_HOST} \
-Dcollection.configName=${COLLECTION_CONFIGNAME}";

echo "***********************************************************";

echo "SOLR COLLECTION NAME: " ${COLLECTION_CONFIGNAME};
echo "SOLR SHARD COUNT: " ${NUM_SHARDS};
echo "SOLR JETTY START PORT: " ${JETTY_PORT}; 
echo "SOLR SCHEMA FILE: " ${SCHEMA};
echo "SOLR SOLRCONFIG FILE: " ${CONFIG};

echo "BASE: " ${BASE};
echo "SOLR HOME DIRECTORY: " ${SOLR_HOME};
echo "SOLR HOSTNAME: " ${SOLR_HOST};
echo "SOLR CORE PROPERTY FILE: " ${CORE_PROPERTIES};
echo "SOLR BOOTSTRAP CONFDIR: " ${BOOTSTRAP_CONFDIR};
echo "SOLR ZOOKEEPER(S): " ${ZK_HOST};

echo "SOLR DATA DIR: " ${DATA_DIR};
echo "SOLR LOGGING DIR: " ${LOGS_DIR};

echo "SOLR JETTY STOP PORT: " ${JETTY_STOP_PORT};
echo "SOLR JETTY STOP KEYWORD: " ${JETTY_STOP_KEYWORD};
echo "SOLR JAVA OPTIONS: " ${SOLR_JAVA_OPTS};

echo "***********************************************************";

if [ -d "${CORE_PROPERTIES}" ]
	then
		rm -rf ${CORE_PROPERTIES}
		mkdir ${CORE_PROPERTIES}
		mkdir ${CORE_PROPERTIES}/${COLLECTION_CONFIGNAME}	
		printf '%s\n%s\n%s\n' "name=${COLLECTION_CONFIGNAME}" "config=${CONFIG}" \
		 "schema=${SCHEMA}" > ${CORE_PROPERTIES}/${COLLECTION_CONFIGNAME}/core.properties;
fi

if [ ! -d "${DATA_DIR}" ]
	then
		mkdir ${DATA_DIR}	
fi 

if [ ! -d "${LOGS_DIR}" ]
	then		
		mkdir ${LOGS_DIR}
fi

for (( c=1; c<=${JETTY_SERVER_COUNT}; c++))
do
	if [ ! -d "${DATA_DIR}/${SHARD_DIR_NAME}$c" ]
	then 
		mkdir ${DATA_DIR}/${SHARD_DIR_NAME}$c 	
	 fi 
done

for (( c=1; c<=${JETTY_SERVER_COUNT}; c++ ))
do
	rm -rf ${LOGS_DIR}/${LOG_DIR_NAME}$c
	mkdir ${LOGS_DIR}/${LOG_DIR_NAME}$c	 
done

cd ${SOLR_HOME}

for (( c=1; c<=${JETTY_SERVER_COUNT}; c++ ))
do
	if [ $c -eq 1 ]
	then		
		java ${SOLR_JAVA_OPTS} \
		-Dbootstrap_confdir=${BOOTSTRAP_CONFDIR} \
		-DnumShards=${NUM_SHARDS} \
		-Dsolr.data.dir=${DATA_DIR}/${SHARD_DIR_NAME}$c \
		-Djetty.port=${JETTY_PORT} \
		-DSTOP.PORT=${JETTY_STOP_PORT} \
		-DSTOP.KEY=${JETTY_STOP_PORT}${JETTY_STOP_KEYWORD} \
		-Dsolr.solr.logging=${LOGS_DIR}/${LOG_DIR_NAME}$c/ \
		 -jar start.jar &
		
		echo "STARTED SOLR INSTANCE $c ON JETTY_PORT: ${JETTY_PORT}"
		echo "SOLRCLOUD START TERMINAL COMMAND:"
		echo "java ${SOLR_JAVA_OPTS} -Dbootstrap_confdir=${BOOTSTRAP_CONFDIR} -DnumShards=${NUM_SHARDS} -Dsolr.data.dir=${DATA_DIR}/${SHARD_DIR_NAME}$c -Djetty.port=${JETTY_PORT} -DSTOP.PORT=${JETTY_STOP_PORT} -DSTOP.KEY=${JETTY_STOP_PORT}${JETTY_STOP_KEYWORD} -Dsolr.solr.logging=${LOGS_DIR}/${LOG_DIR_NAME}$c/ -jar start.jar &"
		
		echo ""
		echo "USE THIS COMMAND TO STOP CORE RUNNING ON PORT ${JETTY_PORT}."
		echo "java -DSTOP.PORT=${JETTY_STOP_PORT} -DSTOP.KEY=${JETTY_STOP_PORT}${JETTY_STOP_KEYWORD} -jar ${SOLR_HOME}/start.jar --stop"

		sleep 2
	 else
		java ${SOLR_JAVA_OPTS} \
		-Dsolr.data.dir=${DATA_DIR}/${SHARD_DIR_NAME}$c \
		-Djetty.port=${JETTY_PORT} \
		-DSTOP.PORT=${JETTY_STOP_PORT} \
		-DSTOP.KEY=${JETTY_STOP_PORT}${JETTY_STOP_KEYWORD} \
		-Dsolr.solr.logging=${LOGS_DIR}/${LOG_DIR_NAME}$c/ \
		-jar start.jar &
		
		echo "STARTED SOLR INSTANCE $c ON PORT: ${JETTY_PORT}"
		echo "SOLRCLOUD COMMAND USED TO START THIS CORE:"
		echo "java ${SOLR_JAVA_OPTS} -Dsolr.data.dir=${DATA_DIR}/${SHARD_DIR_NAME}$c -Djetty.port=${JETTY_PORT} -DSTOP.PORT=${JETTY_STOP_PORT} -DSTOP.KEY=${JETTY_STOP_PORT}${JETTY_STOP_KEYWORD} -Dsolr.solr.logging=${LOGS_DIR}/${LOG_DIR_NAME}$c/ -jar start.jar &"
		
		echo ""
		echo "USE THIS COMMAND TO STOP CORE RUNNING ON PORT ${JETTY_PORT}."
		echo "java -DSTOP.PORT=${JETTY_STOP_PORT} -DSTOP.KEY=${JETTY_STOP_PORT}${JETTY_STOP_KEYWORD} -jar ${SOLR_HOME}/start.jar --stop"
	
		sleep 1
	 fi 
	 
	 JETTY_PORT=$((JETTY_PORT+1))
	 JETTY_STOP_PORT=$((JETTY_STOP_PORT+1))
	 echo ""
done

echo "DONE!"
