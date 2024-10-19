#!/bin/sh

# Colors
cend='\033[0m'
darkorange='\033[38;5;208m'
pink='\033[38;5;197m'
purple='\033[38;5;135m'
green='\033[38;5;41m'
blue='\033[38;5;99m'

if [ "$(whoami)" = "root" ] && [ "$GOSU" = 1 ]; then 
    printf "%b" "[entrypoint] Fixing ownership of (sub-)directories and files regardless of change in ownership\n"
    chown -Rf "$CONT_UID":"$CONT_UID" /app

    CERT_PATH=/usr/local/share/ca-certificates
    FILE_PATH="$CERT_PATH"/my-cert.crt
    cp "$CERT_DIR" "$CERT_PATH"
    cat "$FILE_PATH" >> /etc/ssl/certs/ca-certificates.crt
    update-ca-certificates

    printf "%b" "[entrypoint] Changing user using gosu\n"
    exec /app/bin/gosu "$CONT_USER" /app/scripts/docker-entrypoint.sh

# If user is using gosu variant and changing user account
elif [ "$(whoami)" != "root" ] && [ "$GOSU" = 1 ]; then
    printf "%b" "[❌ " "$pink" "entrypoint - Error" "$cend" "] This variant of the image must be run as root user!\n"
    printf "%b" "[❌ " "$pink" "entrypoint - Error" "$cend" "] Please use rootless variant instead.\n"
    exit 1
fi

# Configuration validity check block
if [ -n "$CONFIG_PATH" ] && [ -f "$CONFIG_PATH" ]; then
    printf "%b" "[✨ " "$purple" "entrypoint - Pass" "$cend" "] ✅ CONFIG_PATH is valid!\n"
else
    printf "%b" "[❌ " "$pink" "entrypoint - Error" "$cend" "] No file or path was found in CONFIG_PATH environment variable\n"
    printf "%b" "[❌ " "$pink" "entrypoint - Error" "$cend" "] Users are expected to mount their own configuration and point CONFIG_PATH environmental variable to it's location\n"
    exit 1
fi

# Binary check if block
if [ -z "$FRP_TYPE" ]; then
    printf "%b" "[✨" " $green" "entrypoint" "$cend" "] Checking binary files...\n"
    printf "%b" "[✨ " "$purple" "entrypoint - Info" "$cend" "] Keep in mind that if your binary files are different name, you should point FRP_NAME to a valid name.\n"
    printf "%b" "[✨ " "$purple" "entrypoint - Info" "$cend" "] You can always skip this check by setting FRP_TYPE to SERVER or CLIENT (use correct type for your image)\n"
    command -v /app/bin/"$FRP_NAME" >/dev/null 2>&1 || export FRP_TYPE="CLIENT"
    command -v /app/bin/"$FRP_NAME" >/dev/null 2>&1 || export FRP_TYPE="SERVER"
fi

printf "%b" "$darkorange" " ______        _     _                                             \n(_____ \      | |   | |                                            \n _____) )_   _| |__ | |__  _____  ____ _   _ _____  ____ ___ _____ \n|  __  /| | | |  _ \|  _ \| ___ |/ ___) | | | ___ |/ ___)___) ___ |\n| |  \ \| |_| | |_) ) |_) ) ____| |    \ V /| ____| |  |___ | ____|\n|_|   |_|____/|____/|____/|_____)_|     \_/ |_____)_|  (___/|_____)\n" "$cend";
printf "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n"
printf "%b" "🗒️ " "$blue" "Setup Guide " "$cend" "- https://github.com/rubberverse/qor-frp/Setup.md \n"
printf "%b" "📁 " "$green" "GitHub Repository " "$cend" "- https://github.com/rubberverse/qor-frp \n"
printf "%b" "🦆 Hey there, thank you for using my images! In case you run into issues please report them on our GitHub repository\n"

if [ "$FRP_TYPE" = "CLIENT" ]; then
    printf "%b" "[✨" " $green" "entrypoint" "$cend" "] Starting frp client\n"
    exec /app/bin/frpc -c "$CONFIG_PATH" "$EXTRA_ARGUMENTS"
elif [ "$FRP_TYPE" = "SERVER" ]; then
    printf "%b" "[✨" " $green" "entrypoint" "$cend" "] Starting frp server\n"
    exec /app/bin/frps -c "$CONFIG_PATH" "$EXTRA_ARGUMENTS"
fi
