# K3s High Availability Configuration with Ansible

This Ansible playbook configures high availability for your K3s cluster using kube-vip for control plane HA and MetalLB for service load balancing.

## Prerequisites

- A running K3s cluster with multiple server nodes (at least 3 recommended for true HA)
- kubectl configured to access your cluster
- Helm installed (if using Rancher)
- Ansible installed on your local machine

## Directory Structure

```
k3s-ha-ansible/
├── k3s-ha.yml                   # Main playbook
├── vars/
│   └── k3s-ha.yml               # Variable definitions
└── templates/
    ├── kube-vip.yaml.j2         # Template for kube-vip DaemonSet
    └── metallb-config.yaml.j2   # Template for MetalLB configuration
```

## Configuration

1. Edit the `vars/k3s-ha.yml` file to match your environment:
   - Set `vip_address` to a free IP in your network for the K3s API
   - Set `vip_interface` to match your server nodes' network interface
   - Adjust the `metallb_ip_range` to a range of free IPs for your LoadBalancer services

2. Make sure your server nodes have the label `node-role.kubernetes.io/master=true`:
   ```bash
   # Check current labels
   kubectl get nodes --show-labels
   
   # Add the label if needed
   kubectl label node <server-node-name> node-role.kubernetes.io/master=true
   ```

## Usage

1. Create the directory structure and copy files from this repository.

2. Run the playbook:
   ```bash
   ansible-playbook k3s-ha.yml
   ```

3. After completion, update your kubeconfig to use the VIP:
   ```bash
   kubectl config set-cluster my-cluster --server=https://192.168.5.100:6443
   ```

## What This Playbook Does

1. **kube-vip**:
   - Deploys kube-vip as a DaemonSet on server nodes
   - Configures a Virtual IP (VIP) for the K3s API endpoint
   - Ensures high availability of the control plane

2. **MetalLB**:
   - Deploys MetalLB components
   - Configures an IP address pool for LoadBalancer services
   - Sets up layer 2 mode (ARP) for IP advertisement

3. **Rancher** (if installed):
   - Updates Rancher to use LoadBalancer type
   - Configures it for high availability with multiple replicas

## Verification

After running the playbook, verify the installation:

1. Check kube-vip is running:
   ```bash
   kubectl get pods -n kube-system -l name=kube-vip
   ```

2. Check MetalLB is running:
   ```bash
   kubectl get pods -n metallb-system
   ```

3. Verify the VIP is responding:
   ```bash
   curl -k https://192.168.5.100:6443
   ```

4. Check LoadBalancer services have been assigned IPs:
   ```bash
   kubectl get svc --all-namespaces | grep LoadBalancer
   ```

## Troubleshooting

- If kube-vip pods are not starting, check if the interface name is correct
- If MetalLB is not assigning IPs, verify the IP range is available
- For network connectivity issues, check firewall rules and network segmentation