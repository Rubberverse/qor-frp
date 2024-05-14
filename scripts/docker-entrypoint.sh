#!/bin/sh

# Colors
cend='\033[0m'
darkorange='\033[38;5;208m'
pink='\033[38;5;197m'
purple='\033[38;5;135m'
green='\033[38;5;41m'
blue='\033[38;5;99m'

if [ "$(whoami)" = "root" ]; then 
    printf "%b" "[entrypoint] Initial start-up sequence as root\n"
    printf "%b" "[entrypoint] Fixing ownership of (sub-)directories and files regardless of change in ownership\n"
    chown -R "$CONT_UID":"$CONT_UID" /app
    ls -ld /app
    ls -ld /app/bin

    printf "%b" "[entrypoint] Forking off to rootless user using tianon/gosu (docker.io/mrrubberducky/qor-gosu)\n"
    exec /app/bin/gosu "$CONT_USER" /app/scripts/docker-entrypoint.sh
fi

printf "%b" "\n[entrypoint] You're currently running as \"$(whoami)"\"
printf "%b" "\n[entrypoint] Continuing with launch...\n"

if [ -n "$CONFIG_PATH" ] && [ -f "$CONFIG_PATH" ]; then
    printf "%b" "[✨ " "$purple" "entrypoint - Pass" "$cend" "] ✅ CONFIG_PATH is valid!\n"
else
    printf "%b" "[❌ " "$pink" "entrypoint - Error" "$cend" "] No file or path was found in CONFIG_PATH environment variable\n"
    printf "%b" "[❌ " "$pink" "entrypoint - Error" "$cend" "] Users are expected to mount their own configuration and point CONFIG_PATH environmental variable to it's location\n"
    exit 1
fi

command -v /app/bin/frps >/dev/null 2>&1 || { echo >&2 "frps not found"; export FRP_CLIENT=1; }
command -v /app/bin/frpc >/dev/null 2>&1 || { echo >&2 "frpc not found"; export FRP_SERVER=1; }

printf "%b" "$darkorange" " ______        _     _                                             \n(_____ \      | |   | |                                            \n _____) )_   _| |__ | |__  _____  ____ _   _ _____  ____ ___ _____ \n|  __  /| | | |  _ \|  _ \| ___ |/ ___) | | | ___ |/ ___)___) ___ |\n| |  \ \| |_| | |_) ) |_) ) ____| |    \ V /| ____| |  |___ | ____|\n|_|   |_|____/|____/|____/|_____)_|     \_/ |_____)_|  (___/|_____)\n" "$cend";
printf "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n"
printf "%b" "🗒️ " "$blue" "Setup Guide " "$cend" "- https://github.com/rubberverse/qor-frp/Setup.md \n"
printf "%b" "📁 " "$green" "GitHub Repository " "$cend" "- https://github.com/rubberverse/qor-frp \n"
printf "%b" "🦆 Hey there, thank you for using my images! In case you run into issues please report them on our GitHub repository\n"

if [ "$FRP_CLIENT" = 1 ]; then
    printf "%b" "[✨" " $green" "entrypoint" "$cend" "] Starting frp client\n"
    exec /app/bin/frpc -c "$CONFIG_PATH" "$EXTRA_ARGUMENTS"
elif [ "$FRP_SERVER" = 1 ]; then
    printf "%b" "[✨" " $green" "entrypoint" "$cend" "] Starting frp server\n"
    exec /app/bin/frps -c "$CONFIG_PATH" "$EXTRA_ARGUMENTS"
fi