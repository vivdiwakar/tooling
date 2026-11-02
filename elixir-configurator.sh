#!/usr/bin/env bash


SHELL_CONF="${HOME}/.bash_profile"
ASYNC_THRDS=$((`sysctl -a | grep machdep.cpu.core_count | cut -d ':' -f2 | tr -d ' '`*10))


# Install
echo "Installing Erlang OTP Runtime and Elixir ..."
if type brew &> /dev/null
then
	brew reinstall --yes erlang elixir
else
	echo "Homebrew not found, please install Homebrew first: https://brew.sh/"
	exit 1
fi
echo "Install complete."


echo "Setting up Aliases ..."
if [[ -z $(grep "alias erl=" ${SHELL_CONF}) ]]
then 
	echo "Adding Aliases ..."
	echo -e "\n# Added `date +%Y-%m-%d\ @\ %H:%M:%S\ %Z\ %z` by Elixir configurator" >> ${SHELL_CONF}
	echo "export ERL_AFLAGS=\"-kernel shell_history enabled\"" >> ${SHELL_CONF}
	echo "alias erl='erl \"+A ${ASYNC_THRDS}\"'" >> ${SHELL_CONF} 
	echo "alias iex='iex --erl \"+A ${ASYNC_THRDS}\"'" >> ${SHELL_CONF} 
	echo -e "# End Elixir configurator" >> ${SHELL_CONF}
	echo "done."
fi
echo "Aliases setup complete."


echo -e "\nRe-source ${SHELL_CONF} to load aliases and updated PATH to start using Elixir."


exit 0
