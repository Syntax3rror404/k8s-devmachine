#!/bin/bash

# Ensure SSH host keys are available and generate them if they do not exist
HOST_KEY_DIR="/home/dev/ssh_keys"
mkdir -p $HOST_KEY_DIR

if [ ! -f $HOST_KEY_DIR/ssh_host_rsa_key ]; then
    echo "Generating new SSH host keys."
    ssh-keygen -t rsa -f $HOST_KEY_DIR/ssh_host_rsa_key -N '' >/dev/null
    ssh-keygen -t ecdsa -f $HOST_KEY_DIR/ssh_host_ecdsa_key -N '' >/dev/null
    ssh-keygen -t ed25519 -f $HOST_KEY_DIR/ssh_host_ed25519_key -N '' >/dev/null
fi

# Start SSH service with custom host key location
/usr/sbin/sshd -D -o HostKey=$HOST_KEY_DIR/ssh_host_rsa_key \
                -o HostKey=$HOST_KEY_DIR/ssh_host_ecdsa_key \
                -o HostKey=$HOST_KEY_DIR/ssh_host_ed25519_key

# Check if any additional commands were passed and execute them
if [ "$#" -gt 0 ]; then
    exec "$@"
else
    # Keep the container running if no command is provided
    tail -f /dev/null
fi
