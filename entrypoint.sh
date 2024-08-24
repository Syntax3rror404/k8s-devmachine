#!/bin/bash

# Check if SSH host keys are available; if not, generate them
if [ ! -f /etc/ssh/keys/ssh_host_rsa_key ]; then
    echo "Generating new SSH host keys."
    ssh-keygen -A
    cp /etc/ssh/ssh_host_* /etc/ssh/keys/
    chown -R root:root /etc/ssh/keys
    chmod 600 /etc/ssh/keys/*
fi

# Start SSH service
/usr/sbin/sshd -D -f /etc/ssh/sshd_config &

# Check if any additional commands were passed and execute them
if [ "$#" -gt 0 ]; then
    exec "$@"
else
    # Keep the container running if no command is provided
    tail -f /dev/null
fi
