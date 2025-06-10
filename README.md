# K8s DevMachine

Containerized development environment for Kubernetes with SSH access. Perfect for VS Code Remote SSH development.

## ✨ Features

- **Development Tools**: Terraform, Packer, Ansible, Python 3, Git, Vim
- **System Tools**: htop, tmux, mc, mcli (minio cli), curl, jq, ping, dig, dmidecode, lshw
- **Cloud Tools**: MinIO Client, SSH server with key-based auth
- **VS Code Remote SSH ready** - full IDE experience
- **Go development support** - easily install Go SDK
- **Persistent storage** for home directory
- **Non-root user** (UID 1001) with auto-activated Python venv

## 🚀 Quick Start

```bash
# 1. Clone repo
git clone https://github.com/syntax3rror404/k8s-devmachine.git
cd k8s-devmachine

# 2. Add your SSH keys to chart/values.yaml
ssh:
  authorizedKeys: |
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... user@hostname

# 3. Deploy
helm install devmachine ./chart

# 4. Connect
kubectl get svc devmachine-service
ssh -p 2222 dev@<EXTERNAL-IP>
```

## 💻 VS Code Remote SSH

1. Install "Remote - SSH" extension in VS Code
2. Add to `~/.ssh/config`:
```
Host k8s-devmachine
    HostName <EXTERNAL-IP>
    Port 2222
    User dev
```
3. Connect via VS Code: `Ctrl+Shift+P` → "Remote-SSH: Connect to Host"

## 🛠️ Install Additional Tools

### Go Installation
```bash
ssh -p 2222 dev@<EXTERNAL-IP>
cd /tmp
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
tar -xzf go1.21.5.linux-amd64.tar.gz
mv go ~/bin/
go version  # Already in PATH
```

### Node.js
```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

## 🔧 Configuration

Key `values.yaml` options:
```yaml
replicaCount: 1
service:
  type: LoadBalancer  # or NodePort
  port: 2222
persistence:
  size: 10Gi
  storageClass: "longhorn"
ssh:
  authorizedKeys: |
    # Your SSH public keys here
```

## 🔐 Access Options

**SSH Direct**: `ssh -p 2222 dev@<EXTERNAL-IP>`
**Port Forward**: `kubectl port-forward svc/devmachine-service 2222:2222`
**NodePort**: `kubectl patch svc devmachine-service -p '{"spec":{"type":"NodePort"}}'`

## 🐛 Troubleshooting

```bash
# Check status
kubectl get pods -l app=devmachine
kubectl logs -l app=devmachine

# Debug connection
kubectl exec -it devmachine-0 -- ss -tuln | grep 2222

# Storage issues
kubectl get pvc
kubectl describe pvc home-volume-devmachine-0
```

## 📁 Directory Structure

```
/home/dev/
├── .ssh/authorized_keys    # SSH keys
├── venv/                   # Python venv (auto-activated)
├── bin/                    # Your binaries or optional bin/go installation
└── projects/               # Your code
```

## 🔒 Security

- Non-root user (UID 1001)
- Key-based SSH only
- Seccomp profile enabled
- No privilege escalation

---

Perfect for remote development with persistent storage and full tool access with VSCode! 