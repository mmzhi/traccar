#!/bin/bash

# Copyright 2016-2021 Guangzhou Ruishan Information Technology Co. Ltd

set -eo pipefail

#===========================================================================================
# 设置默认值
#===========================================================================================
JVM_XMS=${JVM_XMS:-"1g"}
JVM_XMX=${JVM_XMX:-"1g"}
JAR_FILE=${JAR_FILE:-"/opt/traccar/tracker-server.jar"}
CONFIG_FILE=${CONFIG_FILE:-"/opt/traccar/conf/traccar.xml"}

#===========================================================================================
# JVM 配置，只控制Xms和Xmx等项，其他调优配置需要往后再使用
#===========================================================================================
JAVA_OPT="${JAVA_OPT} -server -Xms${JVM_XMS} -Xmx${JVM_XMX} -Djava.net.preferIPv4Stack=true"

#===========================================================================================
# 应用系统相关配置
#===========================================================================================
JAVA_OPT="${JAVA_OPT} ${JAVA_OPT_EXT}"
JAVA_OPT="${JAVA_OPT} -jar ${JAR_FILE} ${CONFIG_FILE}"

exec java ${JAVA_OPT}