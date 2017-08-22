Overview
========

This project shows how to build a docker image to start GNOME shell in container. In a container, a VNC server is started automatically by `systemd`, and GNOME shell is spawn by the VNC server. When you start a container, you are ready to access the desktop environment in it using your favorite VNC viewer.

If your host machine is Linux or Windows, I don't recommend you use this solution: use X window directly, the app just run as a local native app. The only reason you want to use this is because you want to run your dockerized GUI app on Mac OS. The performance of XQuartz is horrible. A VNC server always has a root window, Gnome-shell make it beatiful. If you don't like a desktop, try to use `xpra`.

Dockerfile
======

* The reason to run `systemd` is: `gnome-shell` needs System DBus. Running `systemd` with `CMD [ "/etc/sbin/init" ]` makes thing simple. You probably can start all necessary services for `gnome-shell` in `~/.vnc/xstartup`, but I never make it work.
* You have to run those `systemd` service clean up after installing Gnome yum packages.
* I remove some of DBus services in order to make `gnome-shell` running faster.
* I build the image with the specified UID and GID so that you can map the folders on your host machine to your container with correct permissions.
* You can create the VNC server systemd service file in `Dockfile`, but your image will have a fixed DISPLAY and PORT. My method is put this functionality into `vnc-gnome.sh` so that I can change the DISPLAY without rebuilding the image.

vnc-gnome.sh
=====
* Generate the systemd service file `vncserver.service`, and mount it into `/lib/systemd/system/multi-user.target.wants` so that `systemd` will run it automatically.
* Use `-SecurityTypes None` so that 
  * you don't have to type password in your VNC viewer. 
  * you don't have to create ~/.vnc/passwd 
  * vncserver won't ask you to create a password when it starts. 
* Use `-geometry 1920x1080` for initial desktop size. You can change it by running `xrandr -S 1920x1200` on command line or use Gnome settings displays to change it.
* The PORT number is computed from DISPLAY.

xstartup
=====

* You need to create `~/my-docker/vnc-gnome/.vnc/xstartup`.
* Make sure this file is user runnable. `chmod u+x ~/my-docker/vnc-gnome/.vnc/xstartup`.
* I need to use SSH key with a pass-phrase for my gitlab server. 
* I also turn off a couple of settings to make `gnome-shell` boot up faster.

Check Gnome Log
======

Enter a BASH with user root 
```
$ docker exec -it vnc-gnome /bin/bash
```

In the container, to check the log of GNOME-shell
```
# journalctl -b 
```

Unresolved issues
=====
I can find the following issues in the log, but haven't figure out a way to remove them. The desktop works very well even those errors or warnings exist.

* Cannot start lo interface.
```log
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[90]: Failed to write '1' to '/
proc/sys/net/ipv4/conf/default/promote_secondaries': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[90]: Failed to write '16' to '
/proc/sys/kernel/sysrq': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[90]: Failed to write '0' to '/
proc/sys/net/ipv4/conf/default/accept_source_route': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[90]: Failed to write '1' to '/
proc/sys/kernel/core_uses_pid': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[90]: Failed to write '1' to '/
proc/sys/net/ipv4/conf/all/promote_secondaries': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[90]: Failed to write '1' to '/
proc/sys/net/ipv4/conf/all/rp_filter': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[90]: Failed to write '1' to '/
proc/sys/net/ipv4/conf/default/rp_filter': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[90]: Failed to write '0' to '/
proc/sys/net/ipv4/conf/all/accept_source_route': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[90]: Failed to write '1' to '/
proc/sys/fs/protected_symlinks': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[90]: Failed to write '1' to '/
proc/sys/fs/protected_hardlinks': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 network[19]: Bringing up loopback interface:  RTNET
LINK answers: Operation not permitted
Aug 22 22:27:06 bb9192aa7e96 network[19]: ERROR    : [/etc/sysconfig/network-scr
ipts/ifup-eth] Failed to bring up lo.
Aug 22 22:27:06 bb9192aa7e96 /etc/sysconfig/network-scripts/ifup-eth[127]: 
Failed to bring up lo.
Aug 22 22:27:06 bb9192aa7e96 network[19]: [FAILED]
Aug 22 22:27:06 bb9192aa7e96 network[19]: RTNETLINK answers: Operation not permi
tted
Aug 22 22:27:06 bb9192aa7e96 network[19]: RTNETLINK answers: Operation not permi
tted
Aug 22 22:27:06 bb9192aa7e96 network[19]: RTNETLINK answers: Operation not permi
tted
Aug 22 22:27:06 bb9192aa7e96 network[19]: RTNETLINK answers: Operation not permi
tted
Aug 22 22:27:06 bb9192aa7e96 network[19]: RTNETLINK answers: Operation not permi
tted
Aug 22 22:27:06 bb9192aa7e96 network[19]: RTNETLINK answers: Operation not permi
tted
Aug 22 22:27:06 bb9192aa7e96 network[19]: RTNETLINK answers: Operation not permi
tted
Aug 22 22:27:06 bb9192aa7e96 network[19]: RTNETLINK answers: Operation not permi
tted
Aug 22 22:27:06 bb9192aa7e96 network[19]: RTNETLINK answers: Operation not permi
tted
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[141]: Failed to write '1' to '
/proc/sys/kernel/core_uses_pid': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[141]: Failed to write '1' to '
/proc/sys/net/ipv4/conf/default/rp_filter': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[141]: Failed to write '1' to '
/proc/sys/fs/protected_hardlinks': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[141]: Failed to write '1' to '
/proc/sys/fs/protected_symlinks': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[141]: Failed to write '16' to 
'/proc/sys/kernel/sysrq': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[141]: Failed to write '0' to '
/proc/sys/net/ipv4/conf/default/accept_source_route': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[141]: Failed to write '0' to '
/proc/sys/net/ipv4/conf/all/accept_source_route': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[141]: Failed to write '1' to '
/proc/sys/net/ipv4/conf/all/rp_filter': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[141]: Failed to write '1' to '
/proc/sys/net/ipv4/conf/default/promote_secondaries': Read-only file system
Aug 22 22:27:06 bb9192aa7e96 systemd-sysctl[141]: Failed to write '1' to '
/proc/sys/net/ipv4/conf/all/promote_secondaries': Read-only file system
```
* Cannot start `gnome-keyring-daemon`
```log
Aug 22 22:27:09 bb9192aa7e96 gnome-session[148]: WARNING: Failed to start 
app: Unable to start application: Failed to execute child process "/usr/bin/gnom
e-keyring-daemon" (Operation not permitted)
Aug 22 22:27:09 bb9192aa7e96 gnome-session[148]: gnome-session[148]: WARNING: Fa
iled to start app: Unable to start application: Failed to execute child process 
"/usr/bin/gnome-keyring-daemon" (Operation not permitted)
```
* Need to disable bluez
```log
[pulseaudio] bluez5-util.c: 
GetManagedObjects() failed: org.freedesktop.DBus.Error.ServiceUnknown: The name 
org.bluez was not provided by any .service files
```
