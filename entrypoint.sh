#!/bin/bash

# Start SSH service
/usr/sbin/sshd -D -f /etc/ssh/sshd_config &

# Check if any additional commands were passed and execute them
if [ "$#" -gt 0 ]; then
    exec "$@"
else
    # Keep the container running if no command is provided
    tail -f /dev/null
fi
