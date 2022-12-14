#!/usr/bin/env bash

[ $EUID -eq 0 ] || { echo 'must be root' >&2; exit 1; }

set -o errexit
set -o xtrace

[ -x "/usr/local/bin/kind" ] && { echo "kind already installed"; exit 0; }

curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
chmod +x /usr/local/bin/kind

wget -O /usr/local/bin/kind-with-registry.sh https://kind.sigs.k8s.io/examples/kind-with-registry.sh
chmod +x /usr/local/bin/kind-with-registry.sh

cd /usr/local/bin
patch << EOF
--- a/kind-with-registry.sh
+++ b/kind-with-registry.sh
@@ -14,6 +14,12 @@
 cat <<EOF | kind create cluster --config=-
 kind: Cluster
 apiVersion: kind.x-k8s.io/v1alpha4
+nodes:
+- role: control-plane
+- role: worker
+- role: worker
+networking:
+  disableDefaultCNI: true
 containerdConfigPatches:
 - |-
   [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:\${reg_port}"]
EOF
