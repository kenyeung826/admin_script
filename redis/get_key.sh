#!/bin/bash


if  [[ ! -x "$(command -v redis-cli)" ]]
then
	echo "redis-cli could not be found"
	exit 1
fi

function m_usage() {
        echo " "
        echo "Usage: Get key value in Redis"
        echo ""
		echo "Mandatory:"		
		echo "  -k | --key ARG    		: ARG is the key of the redis"
        echo "Optional:"		
		echo "  -h | --host ARG       	: ARG is the host to connect"
		echo "  -P | --port ARG       	: ARG is the port to connect"
}

host=""
port=""
key=""

while [ "$1" != "" ]; do
    case $1 in
        -s | --host )         	shift; host=$1;;
		-P | --port )         	shift; port=$1;;
        -k | --key )      		shift; key=$1;; 			
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

set +e
PING=$(redis-cli $server PING 2>/dev/null )
set -e
if [ "$PING" = "PONG" ]
then
	type=$(redis-cli --raw $server TYPE $key 2>/dev/null)	
	command=""
	case $type in 
		"string" )       	command="GET $key";;
	esac
	if [ -z "$command" ]
	then
		echo "$key incorrect type"
	else
		result=$(redis-cli --raw $server $command 2>/dev/null)
		echo $result
	fi	
	
	result=$(redis-cli --raw $server $command 2>/dev/null)
	echo $result
else
	echo "$server cannot connect"
fi