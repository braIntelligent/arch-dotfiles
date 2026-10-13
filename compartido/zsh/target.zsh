# Target para la polybar
settarget() {
    if [ -z "$1" ]; then
        echo "uso: settarget <ip> [nombre]"
        return 1
    fi
    echo "$1 $2" > ~/.config/polybar/target
}
cleartarget() {
    : > ~/.config/polybar/target
}
