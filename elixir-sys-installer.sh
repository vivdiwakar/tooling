#!/usr/bin/env bash

# Error printing
function print_error_and_exit {
	local message="${1}"
	local ret_code=${2}
	echo ${message} && exit ${ret_code}
}

# Check if Erlang is installed and return the OTP version
function get_otp_version {
	local file_suffix="lib/erlang/releases/RELEASES"
	
	if [[ -f "/usr/local/${file_suffix}" ]]
	then
		rel_file="/usr/local/${file_suffix}"
	elif [[ -f "/usr/${file_suffix}" ]]
	then
		rel_file="/usr/${file_suffix}"
	else
		print_error_and_exit "RELEASE file not found" 2
	fi

	cat ${rel_file} |\
		grep release |\
		cut -d, -f3 |\
		sed -e 's/"//g'
}

# Pre checks
[[ $(whoami) != "root" ]] && \
	print_error_and_exit "Need elevated privileges to install Elixir system-wide. Please use 'sudo'" 1

# Set variables
DEST_DIR="/usr/local/lib"
TARGET="${DEST_DIR}/elixir-`cat VERSION`-otp`get_otp_version`"
SYMLINK="${DEST_DIR}/elixir"
SHELL_CONF="/home/${SUDO_USER}/.bashrc"
ASYNC_THRDS=$((`cat /proc/cpuinfo | grep \^processor | wc -l`*10))

# Sanitize
echo "Running pre-install checks and cleaning up ..."
[[ -L "${SYMLINK}" ]] && \
	rm -f ${SYMLINK} && \
	echo "Removed link to Elixir deployment" || \
	echo "Elixir deployment not found"
echo "Pre-install checks complete."

# Install
echo "Installing Elixir `cat VERSION` ..."
[[ -d "${TARGET}" ]] && \
	rm -rf ${TARGET} && \
	echo "Removed existing stale install."

mkdir ${TARGET} && \
	echo "Created target for Elixir deployment ..."
echo "Copying files ..." && \
	cp -vr ./bin ${TARGET} && \
	cp -vr ./lib ${TARGET} && \
	cp -vr ./man ${TARGET} && \
	cp -vr ./CHANGELOG.md ${TARGET} && \
	cp -vr ./LICENSE ${TARGET} && \
	cp -vr ./Makefile ${TARGET} && \
	cp -vr ./NOTICE ${TARGET} && \
	cp -vr ./README.md ${TARGET} && \
	cp -vr ./VERSION ${TARGET}
ln -s ${TARGET} ${SYMLINK} && \
	echo "Created link to Elixir deployment ..."
echo "Install complete."

echo "Setting up Aliases ..."
if [[ -z $(grep "alias erl=" ${SHELL_CONF}) ]]
then 
	echo "Adding Aliases ..."
	echo "export ERL_AFLAGS=\"-kernel shell_history enabled\"" >> ${SHELL_CONF}
	echo "alias erl='erl \"+A ${ASYNC_THRDS}\"'" >> ${SHELL_CONF} 
	echo "alias iex='iex --erl \"+A ${ASYNC_THRDS}\"'" >> ${SHELL_CONF} 
	echo "done."
fi
echo "Aliases setup complete."

echo "Setting up PATH ..."
if [[ -z $(grep "export PATH=" ${SHELL_CONF}) ]]
then
        echo "Adding PATH ..."
	echo "export PATH=${PATH}:${SYMLINK}/bin" >> ${SHELL_CONF}
	echo "done."
else
	if [[ -z $(grep "export PATH=" ${SHELL_CONF} | grep "${SYMLINK}/bin") ]]
	then
		echo "path exists but elixir not set"
		sed -i -e "/^export PATH=/ {s|$|:${SYMLINK}/bin|g}" ${SHELL_CONF}
	fi
fi
echo "PATH setup complete."

echo "Re-source ${SHELL_CONF} to load aliases and updated PATH to start using Elixir."

exit 0
