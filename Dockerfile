# Version arguments
ARG DEBIAN_VERSION=bullseye-slim
ARG TERRAFORM_VERSION=1.9.4
ARG PACKER_VERSION=1.11.2
ARG TFHELPER_VERSION=release
ARG PYTHON_VERSION=3.9

# Base image
FROM debian:${DEBIAN_VERSION}

LABEL maintainer="Syntax3rror404"

# Install basic dependencies and tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    curl \
    git \
    python3 \
    python3-venv \
    python3-pip \
    libffi-dev \
    gcc \
    make \
    openssh-server \
    sshpass \
    jq \
    xorriso \
    openssl \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Terraform in /usr/local/terraform/bin
RUN mkdir -p /usr/local/terraform/bin && \
    curl -L -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip /tmp/terraform.zip -d /usr/local/terraform/bin || (echo "Failed to download or unzip Terraform"; exit 1) && \
    rm /tmp/terraform.zip

# Install Packer in /usr/local/packer/bin
RUN mkdir -p /usr/local/packer/bin && \
    curl -L -o /tmp/packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip /tmp/packer.zip -d /usr/local/packer/bin && rm /tmp/packer.zip

# Install TFE_helper in /usr/local/tf-helper/bin
RUN mkdir -p /usr/local/tf-helper/bin && \
    git clone -b ${TFHELPER_VERSION} https://github.com/hashicorp-community/tf-helper.git /usr/local/tf-helper && \
    ln -s /usr/local/tf-helper/tfh/bin/tfh /usr/local/tf-helper/bin/tfh

# Set up Python environment in /usr/local/venv
COPY ./requirements.txt /tmp/requirements.txt
RUN python3 -m venv /usr/local/venv && \
    /usr/local/venv/bin/pip install --upgrade pip && \
    /usr/local/venv/bin/pip install -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt

# Install MinIO Client in /usr/local/minio/bin
RUN mkdir -p /usr/local/minio/bin && \
    curl -L -o /usr/local/minio/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc && \
    chmod +x /usr/local/minio/bin/mc

# Create non-root user with specific UID/GID
RUN addgroup --gid 1001 devgroup && \
    adduser --uid 1001 --ingroup devgroup --shell /bin/bash --home /home/dev --disabled-password dev && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# SSH configuration for rootless container
RUN mkdir -p /home/dev/.ssh /home/dev/var/run/sshd && \
    ssh-keygen -A && \
    echo 'dev:dev' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    mkdir -p /home/dev/ssh_host_keys && \
    ssh-keygen -t rsa -f /home/dev/ssh_host_keys/ssh_host_rsa_key -N '' && \
    ssh-keygen -t dsa -f /home/dev/ssh_host_keys/ssh_host_dsa_key -N '' && \
    ssh-keygen -t ecdsa -f /home/dev/ssh_host_keys/ssh_host_ecdsa_key -N '' && \
    ssh-keygen -t ed25519 -f /home/dev/ssh_host_keys/ssh_host_ed25519_key -N '' && \
    chown -R dev:devgroup /home/dev/.ssh /home/dev/var/run/sshd /home/dev/ssh_host_keys

# Adjust permissions for /usr/local and home directories
RUN chown -R dev:devgroup /usr/local /home/dev

# Switch to non-root user
USER dev

# Set environment variables, including PATH to specific directories
ENV PATH="/usr/local/terraform/bin:/usr/local/packer/bin:/usr/local/tf-helper/bin:/usr/local/minio/bin:/usr/local/venv/bin:$PATH"
ENV VIRTUAL_ENV="/usr/local/venv"

# Copy entrypoint script
COPY ./entrypoint.sh /home/dev/entrypoint.sh
RUN chmod 755 /home/dev/entrypoint.sh

# Expose SSH port
EXPOSE 2222

# Start the SSH server and any other services via entrypoint.sh
ENTRYPOINT ["/home/dev/entrypoint.sh"]
CMD []
