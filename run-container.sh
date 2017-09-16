#!/usr/bin/env bash
#===============================================================================
#
#          FILE: run-container.sh
# 
#         USAGE: ./run-container.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: ERAN SABALA (sabalah21@gmail.com), 
#  ORGANIZATION: 
#       CREATED: 16/09/17 15:56:20
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

source $__dir/utils.sh

check_container_state()
{
        local __argc=1
        checkArgs $FUNCNAME $__argc $#

        local __name=$1
	containerStatus $__name __resault &> /dev/null

	if [[ "$__resault" == "running" ]]; then
		echo "$__name is already running..."
		exit 0
	fi
}

usage()
{
cat << EOF
usage: $0 options

This script runs a new cross instance for you.

OPTIONS:
   -h      show this message
   -n      container name
   -v      Volume to mount the cross tools into
EOF
}

while getopts ":h:n:v:" OPTION
do
     case $OPTION in
         n)
             CONTAINER_NAME=${OPTARG}
             ;;
         v)
             VOLUME_PATH=${OPTARG}
             ;;
         *)
             usage
             exit 1
             ;;
     esac
done

checkOption CONTAINER_NAME
checkOption VOLUME_PATH
check_container_state $CONTAINER_NAME

setVal VOLUME_OPT "-v $VOLUME_PATH:/opt/cross"
mkdir -p $VOLUME_PATH
killContainer $CONTAINER_NAME false

CMD="docker run $VOLUME_OPT \
		--name="${CONTAINER_NAME}" \
                --restart=always \
                -itd \
                uros:cross /opt/entry.sh"

echo "********************"
echo "       cross        "
echo "********************"

eval $CMD
