FROM ubuntu:14.04.3

#RUN apt-get install vim net-tools iproute2 strace -y

RUN mkdir -p /home/cloudstats_agent
WORKDIR /home/cloudstats_agent

COPY out/cloudstats-agent-1.4.3.23-linux-x86_64.tar.gz /home/cloudstats_agent/cloudstats-agent.tar.gz

RUN tar zvxf cloudstats-agent.tar.gz
