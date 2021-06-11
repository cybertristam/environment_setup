i#!/bin/bash

PATH=/bin:/usr/bin:/sbin:/usr/sbin;export PATH
function log_it() {
	local log_level=${1}
	shift
	local msg=$*
	case ${LOGMECHANISM} in
		1)
			displayit ${log_level} ${msg}
		;;
		2)
			logger -t$0 -plocal4.${log_level} ${msg}
		;;
		*)
			displayit ${log_level} ${msg}
		;;
	esac
}

function displayit() {
	local flag=${1}
	if [ "${flag}" = "-e" ]; then
		shift
	fi
	local msg=$*
	
	echo ${flag} "${msg}" 1>&2
}

function help() {
	displayit "$(echo ${0}|awk -F/ '{print $NF}'|sed 's/[[:space:]]//g'): [-h|-v]"
}

function version() {
	displayit "VERSION: ${VERSION}"
}

function update_ssh_agent_pid() {
	local pid_value=$*
	umask 077 && echo -e "${pid_value}" > ${HOME}/.sshagentpid.$(hostname -s)
}

function main() {
	local value=""
	value=$(ssh-agent -s|grep -vP 'echo\s+Agent\s+pid\s+[0-9]+')
	eval ${value}
	ssh-add
	ssh-add ${HOME}/.ssh/git_id_rsa
	update_ssh_agent_pid ${value}
}

case $# in
	0)
		main
	;;
	1)
		if [ "${1}" = "-h" ] || [ "${1}" = "--help" ] ; then
			help
		elif [ "${1}" = "-v" ] || "${1}" = "--version" ] ; then
			version
		fi
	;;
	*)
		help
	;;
esac