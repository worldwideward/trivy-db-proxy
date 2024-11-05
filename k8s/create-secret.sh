#!/bin/bash

namespace=$1
password=$2

if [ -z "$namespace" ]; then
	echo "[ERROR] Please provide a namespace"
	echo "[ERROR] example: create-secret.sh [namespace] [password]"
	exit 1
fi

if [ -z "$password" ]; then
	echo "[ERROR] Please provide a password"
	echo "[ERROR] example: create-secret.sh [namespace] [password]"
	exit 1
fi

kubectl create secret generic oras-registry \
	-n $namespace \
	--from-literal=password=$password
