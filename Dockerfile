FROM ubuntu:15.04

RUN apt-get install vim net-tools iproute2 -y

RUN mkdir -p /home/cloudstats_agent
WORKDIR /home/cloudstats_agent

COPY out/cloudstats-agent-1.0.6-linux-x86_64.tar.gz /home/cloudstats_agent/cloudstats-agent.tar.gz

RUN tar zvxf cloudstats-agent.tar.gz
