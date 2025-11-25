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
'convert_to_jpeg.sh' -> '/home/vivd/.local/bin/convery_to_jpeg.sh'
...
```

Then in **Thunar**: *Edit* -> *Configure custom actions...* -> Click on the `+` sign, and follow the instructions in the comments at the top of each `*_action.sh` file.
