FROM ubuntu:14.04.3

RUN apt-get install vim net-tools iproute2 strace curl -y

RUN mkdir -p /home/cloudstats_agent
WORKDIR /home/

#COPY out/cloudstats-agent-1.5.0.34-linux-x86_64.tar.gz /home/cloudstats_agent/cloudstats-agent.tar.gz
COPY installer /home/installer
#RUN tar zvxf cloudstats-agent.tar.gz
