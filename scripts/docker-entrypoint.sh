#!/bin/sh

# Colors
cend='\033[0m'
darkorange='\033[38;5;208m'
pink='\033[38;5;197m'
purple='\033[38;5;135m'
green='\033[38;5;41m'
blue='\033[38;5;99m'

# Configuration validity check block
if [ -n "$CONFIG_PATH" ] && [ -f "$CONFIG_PATH" ]; then
    printf "%b" "[✨ " "$purple" "entrypoint - Pass" "$cend" "] ✅ CONFIG_PATH is valid!\n"
else
    printf "%b" "[❌ " "$pink" "entrypoint - Error" "$cend" "] No file or path was found in CONFIG_PATH environment variable.\n"
    printf "%b" "[❌ " "$pink" "entrypoint - Error" "$cend" "] E01: Configuration is invalid, unreadable by current user or non-existent.\n"
    exit 1
fi

printf "%b" "$darkorange" " ______        _     _                                             \n(_____ \      | |   | |                                            \n _____) )_   _| |__ | |__  _____  ____ _   _ _____  ____ ___ _____ \n|  __  /| | | |  _ \|  _ \| ___ |/ ___) | | | ___ |/ ___)___) ___ |\n| |  \ \| |_| | |_) ) |_) ) ____| |    \ V /| ____| |  |___ | ____|\n|_|   |_|____/|____/|____/|_____)_|     \_/ |_____)_|  (___/|_____)\n" "$cend";
printf "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n"
printf "%b" "🗒️ " "$blue" "Setup Guide " "$cend" "- https://github.com/rubberverse/qor-frp/README.md \n"
printf "%b" "📁 " "$green" "GitHub Repository " "$cend" "- https://github.com/rubberverse/qor-frp \n"
printf "%b" "🦆 Hey there, thank you for using my images! In case you run into issues please report them on our GitHub repository\n"

if [ "$FRP_TYPE" = "CLIENT" ]; then
    printf "%b" "[✨" " $green" "entrypoint" "$cend" "] Starting frp client\n"
    exec /app/bin/frpc -c "$CONFIG_PATH" "$EXTRA_ARGUMENTS"
elif [ "$FRP_TYPE" = "SERVER" ]; then
    printf "%b" "[✨" " $green" "entrypoint" "$cend" "] Starting frp server\n"
    exec /app/bin/frps -c "$CONFIG_PATH" "$EXTRA_ARGUMENTS"
else
    printf "%b" "[❌ " "$pink" "entrypoint - Error" "$cend" "] Do not modify FRP_TYPE environmental variable\n"
    printf "%b" "[❌ " "$pink" "entrypoint - Error" "$cend" "] E02: FRP_TYPE is not CLIENT or SERVER\n"
    exit 1
fi
