#!/usr/bin/env bash
#===============================================================================
#
#          FILE: entry.sh
# 
#         USAGE: ./entry.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: ERAN SABALA (sabalah21@gmail.com), 
#  ORGANIZATION: 
#       CREATED: 16/09/17 23:24:25
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
set -o errexit                              # Exit on command failure

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

init()
{
	cd /opt/cross-sources/build-gcc      && make install-gcc
	cd /opt/cross-sources/build-binutils && make install
	cd /opt
}

cmd()
{
	bash
}

if [[ -z "$(ls -A  /opt/cross)" ]]; then
	init
	cmd
else
	cmd
fi
