# k8s-iceman

GitOps-managed Kubernetes cluster running on Talos Linux, powered by Argo CD.

Deploys open-source tools from the Solo.io ecosystem: **Istio Ambient Mesh**, **kagent**, and **Agentgateway**. Secrets are managed by **HashiCorp Vault OSS** + **External Secrets Operator**.

## Architecture

```
GitHub Repo (this repo)          Argo CD                    Talos k8s Cluster
┌──────────────────────┐    ┌──────────────┐    ┌─────────────────────────────┐
│  apps/               │───>│  Root App    │───>│  vault                      │
│    vault.yaml        │    │  (App of     │    │    HashiCorp Vault OSS      │
│    external-secrets  │    │   Apps)      │    │                             │
│    istio-*.yaml      │    │              │    │  external-secrets           │
│    kagent-*.yaml     │    │  Syncs git   │    │    External Secrets Op.     │
│    agentgateway-*    │    │  -> cluster  │    │                             │
│    vault-config.yaml │    │              │    │  istio-system               │
│                      │    │  Auto-heal   │    │    istiod (ambient)         │
│  helm-values/        │    │  Auto-prune  │    │    istio-cni + ztunnel      │
│    vault/values.yaml │    └──────────────┘    │                             │
│    kagent/values.yaml│           │            │  kagent                     │
│    ...               │           │            │    kagent (AI agents)       │
│                      │           │            │                             │
│  manifests/          │           │            │  agentgateway-system        │
│    vault-config/     │───────────┘            │    agentgateway (AI proxy)  │
│      ClusterSecret   │                        │                             │
│      ExternalSecret  │  Vault ──> ESO ──> K8s │  longhorn-system (existing) │
└──────────────────────┘    Secrets flow        └─────────────────────────────┘
```

## Repository Structure

```
k8s-iceman/
├── bootstrap/                        # One-time cluster bootstrap
│   ├── install.sh                   # Installs Argo CD + deploys root app
│   ├── vault-init.sh               # Post-deploy: init/unseal Vault + store secrets
│   └── root-app.yaml               # App of Apps - manages everything in apps/
├── apps/                             # Argo CD Application manifests
│   ├── vault.yaml                   # [Wave 0] HashiCorp Vault OSS
│   ├── external-secrets.yaml        # [Wave 0] External Secrets Operator
│   ├── istio-base.yaml              # [Wave 1] Istio CRDs
│   ├── istiod.yaml                  # [Wave 2] Istio control plane (ambient)
│   ├── istio-cni.yaml               # [Wave 3] Istio CNI node agent
│   ├── ztunnel.yaml                 # [Wave 3] Istio zero-trust tunnel
│   ├── kagent-crds.yaml             # [Wave 4] kagent CRDs
│   ├── kagent.yaml                  # [Wave 5] kagent AI agent framework
│   ├── agentgateway-crds.yaml       # [Wave 4] agentgateway CRDs
│   ├── agentgateway.yaml            # [Wave 5] agentgateway AI proxy
│   └── vault-config.yaml            # [Wave 6] SecretStore + ExternalSecrets
├── helm-values/                      # Helm value overrides (GitOps managed)
│   ├── vault/values.yaml            # Standalone mode, Longhorn storage
│   ├── external-secrets/values.yaml
│   ├── istio-base/values.yaml
│   ├── istiod/values.yaml           # ambient profile enabled
│   ├── istio-cni/values.yaml        # ambient profile enabled
│   ├── ztunnel/values.yaml
│   ├── kagent-crds/values.yaml
│   ├── kagent/values.yaml           # References Vault-managed secret
│   ├── agentgateway-crds/values.yaml
│   └── agentgateway/values.yaml
└── manifests/                        # Raw Kubernetes manifests
    └── vault-config/
        ├── cluster-secret-store.yaml # ClusterSecretStore -> Vault
        └── external-secret-kagent.yaml # ExternalSecret for LLM API key
```

## Component Versions

| Component | Version | Chart Source |
|---|---|---|
| Argo CD | v2.14.11 | argoproj/argo-cd |
| HashiCorp Vault | 0.32.0 (app: 1.21.2) | helm.releases.hashicorp.com |
| External Secrets Operator | 2.0.1 | charts.external-secrets.io |
| Istio (ambient) | 1.29.0 | istio-release.storage.googleapis.com/charts |
| kagent | v0.7.19 | ghcr.io/kagent-dev/kagent/helm |
| Agentgateway | v2.2.1 | ghcr.io/kgateway-dev/charts |
| Gateway API CRDs | v1.4.0 | kubernetes-sigs/gateway-api |

## Sync Wave Order

Argo CD deploys components in this order to respect dependencies:

1. **Wave 0** - `vault` + `external-secrets` (secrets infrastructure)
2. **Wave 1** - `istio-base` (Istio CRDs)
3. **Wave 2** - `istiod` (control plane, requires CRDs)
4. **Wave 3** - `istio-cni` + `ztunnel` (data plane, requires istiod)
5. **Wave 4** - `kagent-crds` + `agentgateway-crds` (CRDs for Solo tools)
6. **Wave 5** - `kagent` + `agentgateway` (applications, require their CRDs)
7. **Wave 6** - `vault-config` (SecretStore + ExternalSecrets, requires Vault + ESO)

## Quick Start

### Prerequisites

- Talos Linux k8s cluster running
- `kubectl` configured to talk to the cluster
- Longhorn already installed (storage)
- `jq` installed locally (for vault-init script)

### Step 1: Bootstrap Argo CD

```bash
git clone https://github.com/ProfessorSeb/k8s-iceman.git
cd k8s-iceman
./bootstrap/install.sh
```

This installs Argo CD, Gateway API CRDs, and deploys the root App of Apps. Argo CD will begin deploying all components.

### Step 2: Initialize Vault

After Vault is deployed (check Argo CD UI), run:

```bash
./bootstrap/vault-init.sh
```

This will:
1. Initialize and unseal Vault
2. Enable the KV v2 secrets engine
3. Configure Kubernetes auth for External Secrets Operator
4. Prompt you for your LLM API key and store it in Vault

**Save the unseal key and root token** -- you'll need the unseal key any time Vault restarts.

### Step 3: Verify

```bash
# Check all Argo CD apps are synced
kubectl get applications -n argocd

# Check Vault is running
kubectl get pods -n vault

# Check the secret was created by ESO
kubectl get externalsecrets -n kagent
kubectl get secret kagent-llm-credentials -n kagent
```

### Access UIs

```bash
# Argo CD (https://localhost:8443, user: admin)
kubectl port-forward svc/argocd-server -n argocd 8443:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo

# Vault (http://localhost:8200)
kubectl port-forward -n vault svc/vault-ui 8200:8200

# kagent (http://localhost:8080)
kubectl port-forward -n kagent svc/kagent-ui 8080:8080
```

## Secrets Management

### How it works

```
Vault (source of truth) -> External Secrets Operator -> K8s Secret -> kagent
```

1. Secrets are stored in Vault at `secret/kagent/llm`
2. The `ClusterSecretStore` connects ESO to Vault via Kubernetes auth
3. The `ExternalSecret` pulls `api-key` from Vault and creates a K8s Secret
4. kagent's Helm chart references the K8s Secret for LLM credentials

### Add a new secret to Vault

```bash
kubectl exec -n vault vault-0 -- env VAULT_TOKEN=<token> \
  vault kv put secret/<path> <key>=<value>
```

### Rotate a secret

1. Update the secret in Vault (same command as above)
2. ESO refreshes automatically (every 1h by default, configurable in `external-secret-kagent.yaml`)
3. Restart the consuming pod to pick up the new secret

## Making Changes (GitOps Workflow)

**All changes flow through git. Never `helm install` or `kubectl apply` directly.**

| Action | What to edit | Then |
|---|---|---|
| Update Helm values | `helm-values/<component>/values.yaml` | Push to `main` |
| Upgrade a version | `targetRevision` in `apps/<component>.yaml` | Push to `main` |
| Add a component | New YAML in `apps/` + `helm-values/` | Push to `main` |
| Remove a component | Delete YAML from `apps/` | Push to `main` |
| Add a secret | Store in Vault, add ExternalSecret in `manifests/vault-config/` | Push to `main` |
