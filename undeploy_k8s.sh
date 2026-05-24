#!/bin/bash
ansible all -i inventory.ini -b -m shell -a "kubeadm reset -f"

ansible all -i inventory.ini -b -m shell -a "crictl rm -f \$(crictl ps -a -q) 2>/dev/null || true"
ansible all -i inventory.ini -b -m systemd -a "name=containerd state=restarted"

ansible all -i inventory.ini -b -m shell -a "apt-mark unhold kubelet kubeadm kubectl 2>/dev/null || true"
ansible all -i inventory.ini -b -m apt -a "name=kubelet,kubeadm,kubectl state=absent purge=yes update_cache=yes"
ansible all -i inventory.ini -b -m apt -a "autoremove=yes"

ansible all -i inventory.ini -b -m shell -a "iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X"
ansible all -i inventory.ini -b -m shell -a "ip link delete cni0 || true; ip link delete flannel.1 || true"

ansible all -i inventory.ini -b -m shell -a "rm -rf /etc/kubernetes /var/lib/kubelet /var/lib/etcd /etc/cni/net.d /var/lib/cni /root/.kube ~/.kube /var/run/kubernetes"
