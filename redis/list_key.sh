#!/bin/bash

set -e
if  [[ ! -x "$(command -v redis-cli)" ]]
then
	echo "redis-cli could not be found"
	exit 1
fi

function m_usage() {
        echo " "
        echo "Usage: List set value in Redis"
        echo ""
		echo "Mandatory:"		
		echo "  -k | --key ARG    		: ARG is the key of the redis"
        echo "Optional:"		
		echo "  -h | --host ARG       	: ARG is the host to connect"
		echo "  -P | --port ARG       	: ARG is the port to connect"
		echo "  -l | --limit ARG       	: ARG is the limit to select; default is 10; max is 100"
}

host=""
port=""
key=""
limit=10

while [ "$1" != "" ]; do
    case $1 in
        -h | --host )         	shift; host=$1;;
		-P | --port )         	shift; port=$1;;
        -k | --key )      		shift; key=$1;; 			
		-l | --limit )      	shift; limit=$1;; 			
        * | help)               m_usage; exit 1
    esac
    shift
done

if [ -z "$key" ]
then
	m_usage; 
	exit 1;
fi

server=""

if [[ ! -z "$host" ]]
then
	server=" -h $host "
fi

if [[ ! -z "$port" ]]
then
	server=" -p $port "	
fi

if (( $limit > 100 )); then
	limit=100	
fi

set +e
PING=$(redis-cli $server PING 2>/dev/null )
set -e
if [ "$PING" = "PONG" ]
then
	type=$(redis-cli --raw $server TYPE $key 2>/dev/null)	
	command=""
	case $type in 
		"zset" )       	command="ZRANGE $key 0 $limit";;
	esac
	if [ -z "$command" ]
	then
		echo "$key incorrect type"		
	else		
		redis-cli $server $command 2>/dev/null
	fi	
else
	echo "$server cannot connect"
fi