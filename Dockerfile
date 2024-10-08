# Base image
FROM debian:bullseye-slim

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
    vim \
    iputils-ping \
    dnsutils \
    dmidecode \
    lshw \
    openssh-server \
    sshpass \
    jq \
    xorriso \
    openssl \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Terraform CLI
ARG TERRAFORM_VERSION=1.9.5
RUN curl -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip && \
    unzip -o terraform.zip -d /usr/local/bin/ && \
    rm terraform.zip

# Install Packer
ARG PACKER_VERSION=1.11.2
RUN curl -L "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" -o packer.zip && \
    unzip -o packer.zip -d /usr/local/bin/ && \
    rm packer.zip

# Install TF-Helper
ARG TFHELPER_VERSION=release
RUN git clone -b ${TFHELPER_VERSION} https://github.com/hashicorp-community/tf-helper.git /usr/local/tf-helper && \
    cp /usr/local/tf-helper/tfh/bin/tfh /usr/local/bin/ && \
    rm -rf /usr/local/tf-helper

# Set up Python environment in /usr/local/venv
COPY ./requirements.txt /tmp/requirements.txt
RUN python3 -m venv /usr/local/venv && \
    /usr/local/venv/bin/pip install --upgrade pip && \
    /usr/local/venv/bin/pip install -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt

# Install MinIO Client
RUN curl -L -o /usr/local/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc && \
    chmod +x /usr/local/bin/mc

# Create dev user
RUN groupadd -g 1001 dev && \
    useradd -m -d /home/dev -s /bin/bash -g dev -u 1001 dev && \
    echo "dev:temporary" | chpasswd && \
    passwd -d dev && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Adjust permissions for /usr/local and home directories
RUN chown -R dev:dev /usr/local /home/dev

# Switch to non-root user
USER dev

# Copy entrypoint script
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh

# Set environment variables, including PATH to specific directories
ENV VIRTUAL_ENV="/usr/local/venv"
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Expose SSH port
EXPOSE 2222

# Start the SSH server and any other services via entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD []
