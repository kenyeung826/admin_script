#!/bin/bash
set -e

function m_usage() {
        echo " "
        echo "Usage: Copy file to remote server."
        echo ""
		echo "Mandatory:"		
		echo "  -f | --from_path ARG    : ARG is the from file path"
        echo "  -s | --server ARG       : ARG is the server. Delimit with ;"
		echo ""
		echo "Optional:"		
        echo "  -u | --user ARG         : ARG is the username"
		echo "  -t | --to_path ARG      : ARG is the to file path"
		echo "  -i ARG                  : ARG is private key"
}




from_path=""
servers=""
to_path=""
user=""
private_key=""
private_key_parameter=""

while [ "$1" != "" ]; do
    case $1 in
        -s | --servers )        shift; servers=$1;;
        -f | --from_path )      shift; from_path=$1;;        
		-t | --to_path )        shift; to_path=$1;;        
		-u | --user )           shift; user=$1;;
		-i )					shift; private_key=$1;;        
        * | help)               m_usage; exit 1
    esac
    shift
done

if [ -z "$from_path" ] || [ -z "$servers" ]
then
	m_usage; 
	exit 1;
fi

if [[ ! -z  "$private_key" ]]
then
	private_key_parameter=" -i $private_key "
fi

IFS=';' read -ra server_array <<< "$servers"
for server in ${server_array[@]}; do 
	dest=$server
	if [[ ! -z "$user" ]]
	then
		dest="$user"@"$dest"
	fi
	
	if [[ ! -z "$to_path" ]]
	then
		dest="${dest}":"${to_path}"
	else 
		dest="${dest}:~/"
	fi
		
	echo "copy file ${from_path} to ${dest}"
	scp ${private_key_parameter} ${from_path} ${dest}
	
done


