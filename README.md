# Vanilla Kubernetes Cluster Automated Deployment

This project automates the installation of a production-ready, 3-node Vanilla Kubernetes cluster using Ansible. It provisions a full upstream Kubernetes control plane and worker nodes with optimized networking tailored for AWS-routed VPC infrastructures.

## Cluster Topology
* **node-1**: Control Plane (Master) — `192.168.48.0/22` Pod CIDR
* **node-2**: Worker Node — `192.168.52.0/22` Pod CIDR
* **node-3**: Worker Node — `192.168.56.0/22` Pod CIDR

## Design Decisions

* **Vanilla Kubernetes (`kubeadm`)**: Deployed upstream Kubernetes to ensure 100% CNCF compliance and full control over cluster primitives.
* **Flannel CNI (`host-gw`)**: Configured to utilize high-performance `host-gw` (Host Gateway) mode instead of VXLAN encapsulation. This allows direct routing at the host level, leveraging the pre-existing AWS-routed `/22` subnets without overlay network overhead.
* **Deterministic Pod CIDR Injection**: Bypasses the default Kubernetes API restriction by using an atomic `kubectl replace` workflow via JSON patching. This guarantees each node strictly binds to its designated AWS-allocated `/22` network range on boot.
* **Containerd Engine**: Systemd integration enabled with `SystemdCgroup = true` out-of-the-box to meet strict modern Kubernetes requirements.
* **Idempotent deployment**: The deployment is completely idempotent (can be run multiple times safely without breaking things).

## Prerequisites
* Ansible installed on your local machine.
* Your SSH key (user-6.key) placed in the correct path with 'chmod 400' permissions.

## How to run
* Adjust inventory.ini and groups_vars/all.ini to suit your needs.
* Run the Ansible playbook to configure all nodes and bootstrap the cluster: ./deploy_k8s.sh

--- PROJECT STRUCTURE ---
    inventory.ini    : Defines IPs, roles, and SSH settings.
    site.yml         : The main orchestrator file.
    group_vars/      : Holds global configuration (like K3s version).
    roles/common/    : Prepares OS and prerequisites.
    roles/k8s_master/: Installs master node and generates connection tokens.
    roles/k8s_worker/: Joins worker nodes to the master.
