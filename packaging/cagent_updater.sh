#!/bin/sh

export INSTALL_PATH="/home/cloudstats_agent"

while :
do
	/home/cloudstats_agent/cloudstats-agent --update
	sleep 5m
done
