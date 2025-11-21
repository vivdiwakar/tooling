#!/usr/bin/env bash

# Error printing
function print_error_and_exit {
	local message="${1}"
	local ret_code=${2}
	echo -e ${message} && exit ${ret_code}
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
		print_error_and_exit "RELEASE file not found" 3
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
SYMLINK="${DEST_DIR}/elixir"
SHELL_CONF="/home/${SUDO_USER}/.bashrc"
ASYNC_THRDS=$((`cat /proc/cpuinfo | grep \^processor | wc -l`*10))
JOBS=$((`nproc` * 2))
if [[ -z ${1} ]]
then
	print_error_and_exit "Usage: sudo ${0} x.yy.zz" 2
else
	TAG_VERSION="${1}"
	TARGET="${DEST_DIR}/elixir-${TAG_VERSION}-otp`get_otp_version`"
fi

# Sanitize
echo "Running pre-install checks and cleaning up ..."
[[ -L "${SYMLINK}" ]] && \
	rm -f ${SYMLINK} && \
	echo "Removed link to Elixir deployment" || \
	echo "Elixir deployment not found"
echo "Pre-install checks complete."

# Build
git branch | grep ${TAG_VERSION} 2>&1 > /dev/null
if [[ ${?} -eq 0 ]]
then
	echo "Branch v${TAG_VERSION} found; switching ..."
	sudo -u ${SUDO_USER} git checkout v${TAG_VERSION}
else
	echo "Branch v${TAG_VERSION} not found; creating and checking out ..."
	sudo -u ${SUDO_USER} git checkout tags/v${TAG_VERSION} -b v${TAG_VERSION}
fi

echo "Building (using ${JOBS} jobs) ..."
sudo -u ${SUDO_USER} make -j ${JOBS} clean
sudo -u ${SUDO_USER} make -j ${JOBS}
echo "Build complete."

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
	echo "# Added `date +%Y-%m-%d\ @\ %H:%M:%S\ %Z\ %z` by Elixir configurator" >> ${SHELL_CONF}
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
	echo -e "export PATH=\${PATH}:${SYMLINK}/bin\n# End config\n" >> ${SHELL_CONF}
	echo "done."
else
	if [[ -z $(grep "export PATH=" ${SHELL_CONF} | grep "elixir") ]]
	then
		echo "path exists but Elixir not set"
		sed -i.bak.0 -e "/^export PATH=/ {s|$|:${SYMLINK}/bin|g}" ${SHELL_CONF}
	else
		echo "path exists and Elixir set, checking PATH"
		if [[ -z $(grep "export PATH=" ${SHELL_CONF} | grep "${SYMLINK}/bin") ]]
		then
			sed -i.bak.1 -r 's|(.*)[=:].*elixir/bin|\1|g' ${SHELL_CONF}
			sed -i.bak.2 -e "/^export PATH=/ {s|$|:${SYMLINK}/bin|g}" ${SHELL_CONF}
		else
			echo "PATH set correctly"
		fi
	fi
fi
echo "Cleaning up ..."
	rm -f ${SHELL_CONF}.bak.*
echo "PATH setup complete."

echo "Re-source ${SHELL_CONF} to load aliases and updated PATH to start using Elixir."

exit 0
