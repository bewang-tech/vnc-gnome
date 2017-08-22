DISPLAY=:7
PORT=$(printf "59%02d" $(echo $DISPLAY | sed -e "s/://"))
LOCAL_DIR=~/my-docker/vnc-gnome
DOCKER_IMAGE=bwang-vnc-gnome

cat > $LOCAL_DIR/.vnc/vncserver.service <<EOF
[Unit]
Description=Remote desktop service (VNC)
After=syslog.target network.target

[Service]
Type=forking
# Clean any existing files in /tmp/.X11-unix environment
ExecStartPre=/bin/sh -c '/usr/bin/vncserver -kill $DISPLAY > /dev/null 2>&1 || :'
ExecStart=/usr/sbin/runuser -l $USER -c "/usr/bin/vncserver $DISPLAY -SecurityTypes None -geometry 1920x1080"
PIDFile=/home/$USER/.vnc/%H$DISPLAY.pid
ExecStop=/bin/sh -c '/usr/bin/vncserver -kill $DISPLAY > /dev/null 2>&1 || :'

[Install]
WantedBy=multi-user.target
EOF

docker run --rm \
  --name vnc-gnome \
  --cap-add sys_admin \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -e DISPLAY=$DISPLAY \
  -p $PORT:$PORT \
  -v $LOCAL_DIR/.vnc/vncserver.service:/lib/systemd/system/multi-user.target.wants/vncserver.service \
  -v $LOCAL_DIR:/home/$USER \
  $DOCKER_IMAGE
