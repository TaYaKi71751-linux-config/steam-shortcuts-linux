#!/bin/sh
# All Rights to /usr/bin/steamos-nested-desktop

CURRENT_WIDTH_HEIGHT="$(xrandr --current | grep connected | cut -d '+' -f1 | rev | cut -d ' ' -f1 | rev | tr -d '\n' | tr -d '\r')"

WIDTH=`echo ${CURRENT_WIDTH_HEIGHT} | cut -d "x" -f1 | tr -d '\n' | tr -d '\r' | tr -d ' '`

HEIGHT=`echo ${CURRENT_WIDTH_HEIGHT} | rev | cut -d "x" -f1 | rev | tr -d '\n' | tr -d '\r' | tr -d ' '`

echo ${WIDTH} ${HEIGHT}
mkdir $XDG_RUNTIME_DIR/nested_plasma -p
cat <<EOF > $XDG_RUNTIME_DIR/nested_plasma/kwin_wayland_wrapper
#!/bin/sh
/usr/bin/kwin_wayland_wrapper --width ${WIDTH} --height ${HEIGHT} --no-lockscreen \$@
EOF


dbus-run-session startplasma-wayland

rm $XDG_RUNTIME_DIR/nested_plasma/kwin_wayland_wrapper
