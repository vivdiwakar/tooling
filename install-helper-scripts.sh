#!/usr/bin/env bash


SHELL_CONF="${HOME}/.bash_profile"
SOURCE="./helper-scripts"
DESTINATION="${HOME}/.local/bin"


# Setup
if [[ ! -d ${DESTINATION} ]]
then
	echo "Creating ${DESTINATION} ..."
	mkdir -pv ${DESTINATION}
fi


# Install
echo "Installing helper scripts ..."
for FILE in ${SOURCE}/*
do
	if [[ -f ${FILE} ]]
	then
		cp -vf ${FILE} ${DESTINATION}/
		chmod +x ${DESTINATION}/$(basename ${FILE})
	fi
done
echo "Install complete."


echo -e "\nSetting up Aliases ..."
echo ${PATH} | grep ".local/bin" > /dev/null
if [[ ${?} -ne 0 ]]
then
	echo "Adding ${DESTINATION} to PATH ..."
	echo "export PATH=\"${DESTINATION}:\$PATH\"" >> ${SHELL_CONF}
	echo "done."
else
	echo "${DESTINATION} already in PATH, no action needed."
fi
echo -e "\nRe-source ${SHELL_CONF} to load aliases and updated PATH to start using helper scripts."
echo -e "\nAliases setup complete."


exit 0
