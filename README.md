# K8s DevMachine

A containerized development environment for Kubernetes that provides a VM-like dev experience with SSH access.

## ✨ Features

- **Complete development toolkit** with pre-installed tools:
  - Terraform
  - Packer
  - Ansible with Python libraries
  - Git, Vim, SSH utilities
  - MinIO Client
- **SSH access** on port 2222
- **Persistent storage** for home directory
- **Secure configuration** with non-root user
- **Python virtual environment** auto-activated
- **Customizable SSH keys** via ConfigMap

## 🚀 Quick Start

### Prerequisites

- Kubernetes cluster (>= 1.20)
- Helm 3.x
- Storage class (Longhorn recommended)
- LoadBalancer support (for external access)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/syntax3rror404/k8s-devmachine.git
cd k8s-devmachine
```

2. **Configure SSH keys**
Edit `chart/values.yaml` and add your public SSH keys:

```yaml
ssh:
  authorizedKeys: |
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... user@hostname
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@hostname
```

3. **Deploy with Helm**
```bash
helm install devmachine ./chart
```

4. **Get external IP and connect**
```bash
kubectl get svc devmachine-service
ssh -p 2222 dev@<EXTERNAL-IP>
```

## 🔧 Configuration

### values.yaml

```yaml
replicaCount: 1

image:
  source: ghcr.io/syntax3rror404/k8s-devmachine@sha256:...
  pullPolicy: IfNotPresent

service:
  type: LoadBalancer
  port: 2222
  targetPort: 2222

persistence:
  enabled: true
  size: 10Gi
  storageClass: "longhorn"

ssh:
  authorizedKeys: |
    # Add your SSH public keys here
```

### Resource limits (optional)

```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "2Gi"
    cpu: "1000m"
```

## 🔐 Access

### SSH Connection
```bash
# Get external IP
EXTERNAL_IP=$(kubectl get svc devmachine-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Connect via SSH
ssh -p 2222 dev@$EXTERNAL_IP
```

### Port Forwarding (alternative)
```bash
kubectl port-forward svc/devmachine-service 2222:2222
ssh -p 2222 dev@localhost
```

## 📁 Container Structure

```
/home/dev/
├── .ssh/authorized_keys    # Your SSH keys
├── .bashrc                 # Shell configuration
├── venv/                   # Python virtual environment
├── ssh_keys/              # SSH host keys (persistent)
└── run/                   # Runtime files
```

## 🛠️ Development

### Building the image

The container image is automatically built via GitHub Actions on push to master branch.

For local development:
```bash
docker build -t k8s-devmachine .
docker run -p 2222:2222 k8s-devmachine
```

### Installed Tools

- **Infrastructure**: Terraform, Packer, TF-Helper
- **Configuration Management**: Ansible with extensive Python libraries
- **Utilities**: Git, Vim, curl, jq, openssh, MinIO client
- **System Tools**: ping, dig, dmidecode, lshw

## 🐛 Troubleshooting

### Common Issues

**SSH connection refused**
```bash
# Check pod status
kubectl get pods -l app=devmachine

# View logs
kubectl logs -l app=devmachine

# Debug inside pod
kubectl exec -it devmachine-0 -- /bin/bash
```

**LoadBalancer pending**
```bash
# Use NodePort instead
kubectl patch svc devmachine-service -p '{"spec":{"type":"NodePort"}}'

# Or use port-forwarding
kubectl port-forward svc/devmachine-service 2222:2222
```

**Storage issues**
```bash
# Check storage class
kubectl get storageclass

# Check PVC status
kubectl get pvc
```

### Debug Commands

```bash
# Check service endpoints
kubectl get endpoints devmachine-service

# Describe pod for events
kubectl describe pod devmachine-0

# Test SSH service inside pod
kubectl exec devmachine-0 -- ss -tuln | grep 2222
```

## 📊 Operations

### Backup
```bash
# Backup home directory
kubectl exec devmachine-0 -- tar czf - /home/dev > backup.tar.gz

# Restore
kubectl exec -i devmachine-0 -- tar xzf - -C / < backup.tar.gz
```

### Updates
```bash
# Update image tag in values.yaml, then:
helm upgrade devmachine ./chart

# Rolling restart
kubectl rollout restart statefulset/devmachine
```

### Scaling
```bash
# Scale to multiple instances
helm upgrade devmachine ./chart --set replicaCount=3
```

## 🔒 Security

- Runs as non-root user (UID 1001)
- Password authentication disabled
- Key-based SSH authentication only
- Seccomp profile enabled
- Read-only root filesystem (where possible)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🙏 Acknowledgments

- Built with Debian Bookworm Slim
- Uses HashiCorp tools (Terraform, Packer)
- Ansible automation platform
- Kubernetes community

---

> **Note**: This development machine is designed for development and testing purposes. Consider additional security measures for production environments.