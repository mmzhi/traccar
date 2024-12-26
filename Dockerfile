# 编译后端程序
FROM gradle:jdk17 as server-builder
WORKDIR /opt/app
COPY . /opt/app
RUN bash ./gradlew assemble

FROM node:22 as frontend-builder
WORKDIR /opt/app
COPY . /opt/app
RUN cd traccar-web && npm install && npm run build

# 使用已编译的server层镜像作为基础镜像
FROM eclipse-temurin:17-jre

ENV TRACCAR_VERSION 6.5

WORKDIR /opt/traccar

ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive

RUN mkdir logs && mkdir data && \
    apt update && \
    apt install -y tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo Asia/Shanghai > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*

COPY --from=server-builder  /opt/app/target/tracker-server.jar /opt/traccar
COPY --from=server-builder  /opt/app/target/lib/ /opt/traccar/lib
COPY --from=server-builder  /opt/app/schema/ /opt/traccar/schema
COPY --from=server-builder  /opt/app/templates/ /opt/traccar/templates
COPY --from=frontend-builder  /opt/app/traccar-web/build/ /opt/traccar/web
COPY docker-entrypoint.sh /usr/local/bin/
COPY ./setup/traccar.xml /opt/traccar/conf/

EXPOSE 8082

ENTRYPOINT ["docker-entrypoint.sh"]