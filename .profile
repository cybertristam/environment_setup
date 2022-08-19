PATH=/bin:/usr/bin:/sbin:/usr/sbin;export PATH

function add_to_path() {
	local values=$*
	local newpath=:
	values=`echo ${values}|sed 's/\:/ /g'`
	for value in ${values};do
		if [ -d ${value} ] ; then
			newpath=${newpath}:${value}
		fi
	done
	newpath=`echo ${newpath}|sed -r 's/\s+//g'|sed 's/:://g'`
	PATH=${newpath}:${PATH};export PATH
}

function set_env_var_dirs() {
	local values=$*
	values=$(echo ${values}|sed 's/\:/ /g')
	for value in ${values}; do
		key=`echo ${values}|awk -F= '{print $1}'`
		value_pair=`echo ${values}|awk -F= '{print $2}'`
		if [ -d ${value_pair} ] || [ -L ${value_pair} ] ; then
			${key}=${value_pair};export ${key}
		fi
	done
}

function source_functions() {
	local functions=$*
	for function in ${functions};do
		if [ -s ${function} ]; then
			. ${function}
		fi
	done
}

function setup_java_env() {
	set_env_var_dirs JAVA_HOME=/usr/java/latest
	if [ -d ${JAVA_HOME} ]; then
		add_to_path ${JAVA_HOME}/bin
	fi
}
add_to_path ${HOME}/bin:/usr/local/bin:/usr/local/sbin

setup_java_env

UMASK="077";export UMASK

source_functions ${HOME}/.aliases

if [ -x /bin/docker ] && [ -s ${HOME}/.docker_aliases ]; then
	if [ "`systemctl is-active docker`" = "active" ]; then
		source_functions ${HOME}/.docker_aliases
		source_functions ${HOME}/.docker_functions
	fi
fi
source_functions ${HOME}/.functions
add_to_path ${HOME}/.local/bin
source_functions ${HOME}/.git_functions
