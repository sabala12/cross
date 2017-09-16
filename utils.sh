#!/usr/bin/env bash

set -o nounset                              # Treat unset variables as an error

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

checkArgs()
{
        local __argc=3
        if [[ "$__argc" -gt "$#" ]]; then
                $FUNCNAME $FUNCNAME $__argc $#
        fi

        local __function_name=$1
        local __expected_args=$2
        local __real_args=$3

        if [[ "$__expected_args" -gt "$__real_args" ]]; then
                echo "$__function_name(): wrong number of arguments"
                echo "$__function_name(): expected $__expected_args, actual $__real_args"
                exit 1
        fi
}

setVal() 
{
        local __argc=2
        checkArgs $FUNCNAME $__argc $#

        local __result_var=$1
        local __result_val=$2
        eval "$__result_var='$__result_val'"
}

printErr()
{
        local __argc=2
        checkArgs $FUNCNAME $__argc $#

        local __err_msg=$1
        local __exit_code=$2
        echo $__err_msg
        local __err=$(declare -f usage > /dev/null; echo $?)
        if [[ $__err == "0" ]]; then
                usage
        fi
        exit $__exit_code
}

checkOption()
{
        local __argc=1
        checkArgs $FUNCNAME $__argc $#
        
        local __value=$(echo "${!1}")
        if [[ -z ${__value} ]]; then
                printErr "option $1 is not set!" 1
        fi
}

stopContainer()
{
        local __argc=1
        checkArgs $FUNCNAME $__argc $#

        local __container_name=$1
        docker stop $__container_name &> /dev/null
}

rmContainer()
{
        local __argc=1
        checkArgs $FUNCNAME $__argc $#

        local __container_name=$1
        docker rm -f $__container_name &> /dev/null
}

containerStatus()
{
        local __argc=2
        checkArgs $FUNCNAME $__argc $#
                
        local __container_name=$1
        local __result=$2

        local __running=$(docker inspect --format="{{ .State.Running }}" $__container_name 2> /dev/null)
        if [[ "$__running" == "true" ]]; then
                setVal $__result "running"

        elif [[ "$__running" == "stopped" ]]; then
                setVal $__result "stopped"

        else
                setVal $__result "unknown"

        fi
}

killContainer()
{
        local __argc=2
        checkArgs $FUNCNAME $__argc $#

        local __container_name=$1
        local __always=$2

        containerStatus $__container_name __container_status

        if [[ "$__container_status" == "unknown" ]]; then
                rmContainer $__container_name
                return
        fi

        if [[ "$__always" == "true" ]]; then
                local __kill_container="y"
        else
                echo -n -e "Enter y to kill $__container_name, or else to continue.\n"; read __kill_container
        fi

        if [[ "$__kill_container" == "y" ]]; then
                docker rm -f $__container_name
        fi
}

