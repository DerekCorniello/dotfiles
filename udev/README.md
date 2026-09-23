# udev rules

These rules are tracked here because they belong to the machine setup, but they
must live under `/etc/udev/rules.d` for udev to use them.

Install the Nape Pro rule with:

```sh
sudo ln -s /home/derekcorn/dotfiles/udev/51-keychron-nape.rules \
  /etc/udev/rules.d/51-keychron-nape.rules
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=hidraw
```
