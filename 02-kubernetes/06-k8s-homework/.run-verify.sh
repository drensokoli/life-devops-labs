#!/usr/bin/env bash
set -e
export KUBECONFIG=/mnt/c/Users/Admin/.kube/config
mkdir -p "$HOME/.local/bin"
rm -f "$HOME/.local/bin/kubectl"
cat > "$HOME/.local/bin/kubectl" <<'EOF'
#!/usr/bin/env bash
"/mnt/c/Program Files/Docker/Docker/resources/bin/kubectl.exe" "$@" | tr -d '\r'
exit "${PIPESTATUS[0]}"
EOF
chmod +x "$HOME/.local/bin/kubectl"
export PATH="$HOME/.local/bin:$PATH"
hash -r
cd /mnt/c/Users/Admin/Desktop/DevOps/life-devops-labs/02-kubernetes/06-k8s-homework
which kubectl
kubectl cluster-info 2>&1 | head -2
echo "--running verify--"
bash ./verify.sh
