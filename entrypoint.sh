#!/bin/bash

# Start SSH service
/usr/sbin/sshd -D -f /home/dev/ssh_host_keys/sshd_config &

# Check if any additional commands were passed and execute them
if [ "$#" -gt 0 ]; then
    exec "$@"
else
    # Keep the container running if no command is provided
    tail -f /dev/null
fi
