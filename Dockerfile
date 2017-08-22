FROM centos:7

ENV container docker

RUN yum install -y gnome-session gnome-terminal gnome-shell gnome-tweak-tool ibus \
   xorg-x11-server-Xvfb vncserver tigervnc-server \
   dejavu-sans-fonts dejavu-sans-mono-fonts dejavu-serif-fonts \
   gnu-free-mono-fonts gnu-free-sans-fonts gnu-free-serif-fonts \
   liberation-mono-fonts liberation-sans-fonts liberation-serif-fonts \
   google-noto-sans-fonts google-noto-sans-ui-fonts google-noto-serif-fonts \
   && yum clean all

RUN ( cd /lib/systemd/system/sysinit.target.wants/; \
      for i in *; do \
        [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; \
      done ) \
    && ( cd /lib/systemd/system/multi-user.target.wants; \
      for i in *; do \
        [ $i == systemd-user-sessions.service ] || rm -f $i; \
      done ) \
    && rm -f /etc/systemd/system/*.wants/*\
    && rm -f /lib/systemd/system/local-fs.target.wants/* \
    && rm -f /lib/systemd/system/sockets.target.wants/*udev* \
    && rm -f /lib/systemd/system/sockets.target.wants/*initctl* \
    && rm -f /lib/systemd/system/basic.target.wants/* \
    && rm -f /lib/systemd/system/anaconda.target.wants/* \
    && rm -f /usr/share/dbus-1/system-services/org.freedesktop.RealtimeKit1.service \
    && rm -f /usr/share/dbus-1/system-services/org.freedesktop.UPower.service \ 
    && rm -f /usr/share/dbus-1/system-services/org.freedesktop.Accounts.service \ 
    && rm -f /usr/share/dbus-1/system-services/org.bluez.service \ 
    && rm -f /usr/share/dbus-1/system-services/org.freedesktop.GeoClue2.service  

ARG GID
ARG UID
ARG USER

RUN groupadd --gid $GID $USER \
    && useradd --uid $UID --gid $GID $USER \
    && echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers 

RUN yum install -y openssh-clients && yum clean all

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/usr/sbin/init"]
