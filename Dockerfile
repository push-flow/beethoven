FROM ubuntu:16.04

MAINTAINER vctrferreira
ENV BASE_PATH=/home/config
ENV CONTAINER_TIMEZONE=America/Sao_Paulo

WORKDIR ${BASE_PATH}

RUN apt-get update
RUN apt-get upgrade -y
RUN apt install -y build-essential tcl 
RUN apt-get install -y wget

RUN wget -qO - https://openresty.org/package/pubkey.gpg | apt-key add -
RUN apt-get -y install software-properties-common
RUN add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main"

RUN apt-get update

RUN apt-get install -y openresty
RUN apt-get install -y supervisor
RUN apt-get install -y tzdata
RUN apt-get install -y git


RUN curl -O http://download.redis.io/redis-stable.tar.gz

RUN tar xzvf redis-stable.tar.gz
RUN cd redis-stable && make && make test && make install


RUN echo ${CONTAINER_TIMEZONE} >/etc/timezone
RUN ln -sf /usr/share/zoneinfo/${CONTAINER_TIMEZONE} /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata

COPY nginx-openresty.conf ${BASE_PATH}/nginx-openresty.conf
COPY supervisor-app.conf /etc/supervisor/conf.d/

COPY entrypoint.sh ${BASE_PATH}

COPY routers/ ${BASE_PATH}/routers
RUN chmod +x ${BASE_PATH}/entrypoint.sh

ENTRYPOINT ${BASE_PATH}/entrypoint.sh
EXPOSE 80