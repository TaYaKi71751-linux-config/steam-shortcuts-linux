#!/bin/sh
# All Rights to /usr/bin/steamos-nested-desktop
# Remove the performance overlay, it meddles with some tasks
unset LD_PRELOAD
CURRENT_WIDTH_HEIGHT="$(xrandr --current | grep connected | cut -d '+' -f1 | rev | cut -d ' ' -f1 | rev | tr -d '\n' | tr -d '\r')"

WIDTH=`echo ${CURRENT_WIDTH_HEIGHT} | cut -d "x" -f1 | tr -d '\n' | tr -d '\r' | tr -d ' '`

HEIGHT=`echo ${CURRENT_WIDTH_HEIGHT} | rev | cut -d "x" -f1 | rev | tr -d '\n' | tr -d '\r' | tr -d ' '`

## Shadow kwin_wayland_wrapper so that we can pass args to kwin wrapper
## whilst being launched by plasma-session
mkdir $XDG_RUNTIME_DIR/nested_plasma -p
cat <<EOF > $XDG_RUNTIME_DIR/nested_plasma/kwin_wayland_wrapper
#!/bin/sh
/usr/bin/kwin_wayland_wrapper --width $WIDTH --height $HEIGHT --no-lockscreen \$@
EOF
chmod a+x $XDG_RUNTIME_DIR/nested_plasma/kwin_wayland_wrapper
export PATH=$XDG_RUNTIME_DIR/nested_plasma:$PATH

dbus-run-session startplasma-wayland

rm $XDG_RUNTIME_DIR/nested_plasma/kwin_wayland_wrapper
