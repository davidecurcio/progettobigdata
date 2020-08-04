#!/bin/bash

MASTER_DNS=$1

./spark/sbin/start-slave.sh spark://$MASTER_DNS:7077