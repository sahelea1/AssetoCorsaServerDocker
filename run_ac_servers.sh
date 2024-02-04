#!/bin/bash

# Start the SSH server
service ssh start

# Function to synchronize folders and copy files
sync_folders_and_copy_files() {
    # Sync directories
    rsync -av --delete /srv/upload/ /srv/servers/

    # Copy contents from /srv/template to each directory in /srv/servers
    for dir in /srv/servers/*; do
        if [ -d "$dir" ]; then
            cp -r /srv/template/* "$dir/"
        fi
    done

    # Copy .ini files
    for dir in /srv/upload/*; do
        if [ -d "$dir" ]; then
            cp "$dir"/*.ini "/srv/servers/$(basename "$dir")/cfg/"
        fi
    done
}

# Function to assign random ports and start acServer in all directories
start_servers() {
    used_ports=()

    for dir in /srv/servers/*; do
        if [ -d "$dir" ]; then
            # Assign random ports
            while true; do
                udp_port=$((RANDOM % 21 + 9600))
                tcp_port=$((RANDOM % 21 + 9600))
                http_port=$((RANDOM % 20 + 8081))

                if [[ ! " ${used_ports[@]} " =~ " ${udp_port} " ]] && \
                   [[ ! " ${used_ports[@]} " =~ " ${tcp_port} " ]] && \
                   [[ ! " ${used_ports[@]} " =~ " ${http_port} " ]]; then
                    used_ports+=($udp_port $tcp_port $http_port)
                    break
                fi
            done

            # Modify the server config files
            sed -i "s/UDP_PORT=.*/UDP_PORT=$udp_port/" "$dir/cfg/server_cfg.ini"
            sed -i "s/TCP_PORT=.*/TCP_PORT=$tcp_port/" "$dir/cfg/server_cfg.ini"
            sed -i "s/HTTP_PORT=.*/HTTP_PORT=$http_port/" "$dir/cfg/server_cfg.ini"

            # Start acServer and log output
            cd "$dir"
            nohup ./acServer &> /proc/1/fd/1 &
        fi
    done
}

# Function to kill all acServer processes
kill_servers() {
    pkill acServer
}

# Monitor for the "start" and "stop" file
while true; do
    if [ -f "/srv/upload/start" ]; then
        kill_servers
        sync_folders_and_copy_files
        start_servers
        rm -f "/srv/upload/start"
    fi

    if [ -f "/srv/upload/stop" ]; then
        kill_servers
        rm -f "/srv/upload/stop"
    fi

    sleep 5
done

