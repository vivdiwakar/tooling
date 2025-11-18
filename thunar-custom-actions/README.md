# Custom Actions for Thunar File Manager

## Installing the actions scripts

Create the destination directory if it doesn't exist.

```sh
$ mkdir -pv ${HOME}/.local/bin
mkdir: created directory '/home/vivd/.local/bin'
```

Ensure `${HOME}/.local/bin` is on the `PATH`, else add and re-source the profile config file.

Copy all `.sh` files to `${HOME}/.local/bin`.

```sh
$ thunar-custom-actions$ cp -v *.sh ${HOME}/.local/bin/
'copy_to_action.sh' -> '/home/vivd/.local/bin/copy_to_action.sh'
'move_to_action.sh' -> '/home/vivd/.local/bin/move_to_action.sh'
'open_terminal_action.sh' -> '/home/vivd/.local/bin/open_terminal_action.sh'
```

Then in **Thunar**: *Edit* -> *Configure custom actions...* -> Click on the `+` sign, and follow the instructions in the comments at the top of each `*_action.sh` file.

