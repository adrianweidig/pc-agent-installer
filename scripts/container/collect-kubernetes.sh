#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-kubernetes-baseline.md}"
{
  echo "# Kubernetes Baseline"
  for cmd in "kubectl config current-context" "kubectl config get-contexts" "kubectl get namespaces" "kubectl get workloads --all-namespaces" "kubectl get svc,ingress --all-namespaces" "kubectl get pv,pvc --all-namespaces" "kubectl get roles,rolebindings,clusterroles,clusterrolebindings --all-namespaces"; do
    echo
    echo "## $cmd"
    echo '```text'
    bash -lc "$cmd" 2>&1 || true
    echo '```'
  done
  echo
  echo "Kubernetes-Secrets werden nicht exportiert."
} > "$OUT"
echo "Erfasst: $OUT"
