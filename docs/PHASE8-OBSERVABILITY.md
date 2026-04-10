# Phase 8 — Observability (Prometheus + Grafana + Alertmanager)

> Full monitoring stack for StudentSphere on AWS EKS via Helm.
> Real-time metrics + dashboards + alerts = full production visibility.
> Part of [multi-cloud-devops-studentsphere](https://github.com/manesaurabh1704-devops/multi-cloud-devops-studentsphere)

---

## 🎯 What is Observability?

```
Without Observability: App is slow — no idea why, when, or what happened
With Observability:    Real-time metrics + dashboards + alerts = full visibility
```

The three pillars of observability:
```
Metrics    → Prometheus (numbers over time — CPU, Memory, Requests)
Dashboards → Grafana (visual graphs and charts)
Alerts     → Alertmanager (notify when something goes wrong)
```

---

## 🛠️ Stack Used

| Tool | Purpose |
|---|---|
| Prometheus | Metrics collection and storage |
| Grafana | Dashboard visualization |
| Alertmanager | Alert routing and notifications |
| kube-state-metrics | Kubernetes resource metrics |
| node-exporter | Node-level hardware metrics |

---

## 🏗️ Architecture

```
Kubernetes Cluster (AWS EKS)
    │
    ├── node-exporter (per node)     ← CPU, Memory, Disk per node
    ├── kube-state-metrics           ← Pod, Deployment, Service metrics
    ├── studentsphere pods           ← App metrics
    └── all namespaces
            │
            ▼
        Prometheus
     (collect + store every 15s)
            │
    ┌───────┴───────┐
    │               │
 Grafana      Alertmanager
(dashboards)   (alert routing)
```

---

## ⚡ How to Install

### Prerequisites
```bash
helm version
kubectl get nodes
```

### Step 1 — Add Helm Repository

```bash
helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts
helm repo update
```

Expected output:
```
"prometheus-community" has been added to your repositories
Update Complete. Happy Helming!
```

### Step 2 — Install kube-prometheus-stack

```bash
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.adminPassword=admin123 \
  --set prometheus.prometheusSpec.retention=7d
```

Expected output:
```
NAME: prometheus
NAMESPACE: monitoring
STATUS: deployed
```

### Step 3 — Verify All Pods Running

```bash
kubectl get pods -n monitoring
```

Expected output:
```
NAME                                                     READY   STATUS
alertmanager-prometheus-kube-prometheus-alertmanager-0   2/2     Running
prometheus-grafana-xxxx                                  3/3     Running
prometheus-kube-prometheus-operator-xxxx                 1/1     Running
prometheus-kube-state-metrics-xxxx                       1/1     Running
prometheus-prometheus-kube-prometheus-prometheus-0       2/2     Running
prometheus-prometheus-node-exporter-xxxx (x4)            1/1     Running
```

### Step 4 — Expose Services

```bash
# Grafana
kubectl patch svc prometheus-grafana -n monitoring \
  -p '{"spec": {"type": "LoadBalancer"}}'

# Prometheus
kubectl patch svc prometheus-kube-prometheus-prometheus -n monitoring \
  -p '{"spec": {"type": "LoadBalancer"}}'

# Alertmanager
kubectl patch svc prometheus-kube-prometheus-alertmanager -n monitoring \
  -p '{"spec": {"type": "LoadBalancer"}}'

# Get all URLs
kubectl get svc -n monitoring | grep LoadBalancer
```

### Step 5 — Access UIs

```
Grafana:      http://<GRAFANA-URL>         admin / admin123
Prometheus:   http://<PROMETHEUS-URL>:9090
Alertmanager: http://<ALERTMANAGER-URL>:9093
```

### Step 6 — View Kubernetes Dashboards in Grafana

```
Grafana → Dashboards → Browse

Key Dashboards:
- Kubernetes / Compute Resources / Cluster
- Kubernetes / Compute Resources / Namespace (Pods)
- Kubernetes / Compute Resources / Node (Pods)
- Kubernetes / Networking / Cluster
```

### Step 7 — View studentsphere Namespace

```
Dashboards → Kubernetes / Compute Resources / Namespace (Pods)
namespace dropdown → select "studentsphere"
```

---

## 📊 Key Metrics Observed

| Metric | Value | Description |
|---|---|---|
| CPU Utilisation | 3.23% | Total cluster CPU usage |
| CPU Limits Commitment | 18.1% | CPU limits configured |
| Memory Utilisation | 54.2% | Total cluster memory |
| studentsphere CPU | 0.565% | App namespace CPU |
| studentsphere Memory | 74.1% | App namespace memory |
| Prometheus Targets | 31 UP | All scrape targets active |
| Alertmanager Alerts | 7 | Active alerts |

---

## 📸 Output / Proof

### Grafana Dashboard List
![Grafana Dashboard](../screenshots/phase8/01-grafana-dashboard.png)

### Kubernetes Cluster Overview
![Kubernetes Cluster](../screenshots/phase8/02-kubernetes-cluster.png)

### StudentSphere Namespace Pods
![StudentSphere Pods](../screenshots/phase8/03-studentsphere-pods.png)

### Prometheus Targets — All UP
![Prometheus Targets](../screenshots/phase8/04-prometheus-targets.png)

### Prometheus Query — up
![Prometheus Query](../screenshots/phase8/05-prometheus-query.png)

### Alertmanager — Active Alerts
![Alertmanager](../screenshots/phase8/06-alertmanager.png)

---

## 🐛 Troubleshooting

### Problem 1 — Pods Pending After Install
```
Error: 0/4 nodes available: Too many pods

Fix: Scale up node group
eksctl scale nodegroup \
  --cluster studentsphere-cluster \
  --name studentsphere-nodes \
  --nodes 4 \
  --nodes-max 5 \
  --region ap-south-1
```

### Problem 2 — Helm Install Already Exists
```
Error: cannot re-use a name that is still in use

Fix: Upgrade instead
helm upgrade prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword=admin123
```

### Problem 3 — Grafana Shows No Data
```
Error: No data in dashboards

Fix: Wait 2-3 minutes after install
Prometheus needs time to scrape initial metrics
```

### Problem 4 — Cannot Access Grafana UI
```
Error: Connection refused

Fix: Check LoadBalancer status
kubectl get svc prometheus-grafana -n monitoring
# Wait for EXTERNAL-IP to be assigned
```

### Problem 5 — Prometheus Target Shows DOWN
```
Error: Target health = DOWN

Fix: Check target endpoint is accessible
kubectl get svc -n studentsphere
kubectl get pods -n studentsphere
```

---

## 🔗 Related Repositories

| Repository | Purpose |
|---|---|
| [multi-cloud-devops-studentsphere](https://github.com/manesaurabh1704-devops/multi-cloud-devops-studentsphere) | Main project |
| [kubernetes-production-setup](https://github.com/manesaurabh1704-devops/kubernetes-production-setup) | K8s manifests |
| [monitoring-observability-stack](https://github.com/manesaurabh1704-devops/monitoring-observability-stack) | Monitoring configs |

---

## 👨‍💻 Author
**Saurabh Mane** — DevOps Engineer
- GitHub: [@manesaurabh1704-devops](https://github.com/manesaurabh1704-devops)

---

> ⭐ Star this repo if you find it helpful!
