#!/bin/bash
set -e

function m_usage() {
        echo " "
        echo "Usage: Run Script File on remote server."
        echo ""
		echo "Mandatory:"		
		echo "  -f | --script_path ARG  : ARG is the script path"
        echo "  -s | --server ARG       : ARG is the server. Delimit with ;"
		echo ""
		echo "Optional:"		
        echo "  -u | --user ARG         : ARG is the username"		
        echo "  -i ARG                  : ARG is private key"
}




script_path=""
servers=""
user=""

while [ "$1" != "" ]; do
    case $1 in
        -s | --servers )        shift; servers=$1;;
        -f | --script_path )      shift; script_path=$1;;        		
		-u | --user )           shift; user=$1;;   
		-i )					shift; private_key=$1;;         
        * | help)               m_usage; exit 1
    esac
    shift
done

if [ -z "$script_path" ] || [ -z "$servers" ]
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
	dest="${dest}"		
	echo "run script ${script_path} on ${dest}"
	ssh ${private_key_parameter} ${dest} 'bash -s ' < ${script_path}	
done


