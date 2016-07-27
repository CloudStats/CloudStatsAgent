#!/bin/sh

export INSTALL_PATH="/home/cloudstats_agent"

while :
do
	bundle exec ruby lib/cloudstats.rb --update
	sleep 5h
done
