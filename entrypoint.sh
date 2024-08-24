#!/bin/bash

# Ensure SSH host keys are available; generate them if they do not exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    echo "Generating new SSH host keys."
    ssh-keygen -A
fi

# Start SSH service
/usr/sbin/sshd -D

# Check if any additional commands were passed and execute them
if [ "$#" -gt 0 ]; then
    exec "$@"
else
    # Keep the container running if no command is provided
    tail -f /dev/null
fi
