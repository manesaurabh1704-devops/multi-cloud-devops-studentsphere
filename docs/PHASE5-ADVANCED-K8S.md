# Phase 5 — Advanced Kubernetes Features

> HPA + Canary + Blue-Green Deployment on AWS EKS
> Part of [multi-cloud-devops-studentsphere](https://github.com/manesaurabh1704-devops/multi-cloud-devops-studentsphere)

---

## 📋 What is Covered

| Feature | File | Status |
|---|---|---|
| HPA — Backend | `k8s/aws/backend-hpa.yaml` | ✅ Complete |
| HPA — Frontend | `k8s/aws/frontend-hpa.yaml` | ✅ Complete |
| Canary Deployment | `k8s/aws/backend-canary.yaml` | ✅ Complete |
| Blue-Green Deployment | `k8s/aws/backend-blue-green.yaml` | ✅ Complete |

---

## 🔄 Feature 1 — HPA (Horizontal Pod Autoscaler)

### What
HPA automatically scales pods up or down based on CPU and memory usage.

### Why
```
Without HPA: Backend = 2 pods (fixed — cannot handle traffic spikes)
With HPA:    Load increases → 2→3→4→5 pods (auto scale up)
             Load decreases → 5→4→3→2 pods (auto scale down)
```

### How

#### Backend HPA
```bash
kubectl apply -f k8s/aws/backend-hpa.yaml
```

`backend-hpa.yaml`:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
  namespace: studentsphere
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 2
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 95
```

#### Frontend HPA
```bash
kubectl apply -f k8s/aws/frontend-hpa.yaml
```

#### Verify HPA Working
```bash
kubectl get hpa -n studentsphere
```

Expected output:
```
NAME           REFERENCE             TARGETS                        MINPODS   MAXPODS   REPLICAS
backend-hpa    Deployment/backend    cpu: 0%/70%, memory: 78%/95%   2         5         2
frontend-hpa   Deployment/frontend   cpu: 1%/70%, memory: 4%/80%    2         5         2
```

#### HPA Details
```bash
kubectl describe hpa backend-hpa -n studentsphere
```

Expected output:
```
Name:         backend-hpa
Namespace:    studentsphere
Reference:    Deployment/backend
Metrics:
  resource cpu:     1% (2m) / 70%
  resource memory:  78% (205330Ki) / 80%
Min replicas:  2
Max replicas:  5
Deployment pods: 2 current / 2 desired
Conditions:
  AbleToScale    True   ReadForNewScale   recommended size matches current size
  ScalingActive  True   ValidMetricFound  HPA calculated replica count
  ScalingLimited False  DesiredWithinRange desired count within acceptable range
```

### Output / Proof
![HPA Working](screenshots/phase5/01-hpa-working.png)

---

## 🐦 Feature 2 — Canary Deployment

### What
Canary deployment sends a small percentage of traffic to a new version before full rollout.

### Why
```
Without Canary: v1 → v2 (100% users affected if bug exists)
With Canary:    v1 (stable, 2 pods) + v2 (canary, 1 pod) → test → full rollout
Traffic split:  2 stable pods + 1 canary pod = ~33% canary traffic
```

### How

```bash
kubectl apply -f k8s/aws/backend-canary.yaml
```

`backend-canary.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-canary
  namespace: studentsphere
  labels:
    app: backend
    track: canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
      track: canary
  template:
    metadata:
      labels:
        app: backend
        track: canary
    spec:
      containers:
        - name: backend
          image: manesaurabh1704devops/studentsphere-backend:v1
```

#### Verify Canary Running
```bash
kubectl get pods -n studentsphere --show-labels | grep canary
```

Expected output:
```
backend-canary-xxxx   1/1   Running   0   2m   app=backend,track=canary
```

#### Check Traffic Split
```bash
kubectl get deployments -n studentsphere
```

Expected output:
```
NAME             READY   UP-TO-DATE   AVAILABLE
backend          2/2     2            2          ← Stable (67% traffic)
backend-canary   1/1     1            1          ← Canary (33% traffic)
```

### Output / Proof
![Canary Deployment](screenshots/phase5/02-canary-deployment.png)

---

## 🔵🟢 Feature 3 — Blue-Green Deployment

### What
Blue-Green maintains two identical environments — Blue (current) and Green (new). Traffic switches instantly between them.

### Why
```
Blue  = Current stable version (v1) — receiving traffic
Green = New version (v2)           — tested in parallel

Switch: Service selector blue → green = zero downtime!
Rollback: Service selector green → blue = instant!
```

### How

```bash
kubectl apply -f k8s/aws/backend-blue-green.yaml
```

`backend-blue-green.yaml` creates:
- `backend-blue` Deployment (v1) — stable
- `backend-green` Deployment (v1/v2) — new version
- `backend-bg-service` Service — points to blue initially

#### Verify Blue-Green Running
```bash
kubectl get deployments -n studentsphere | grep -E "blue|green"
```

Expected output:
```
backend-blue    1/1   1   1   5m
backend-green   1/1   1   1   5m
```

#### Check Current Traffic Target
```bash
kubectl get svc backend-bg-service -n studentsphere \
  -o jsonpath='{.spec.selector}' && echo ""
```

Expected output:
```
{"app":"backend","version":"blue"}
```

#### Switch Traffic — Blue to Green
```bash
kubectl patch svc backend-bg-service -n studentsphere \
  -p '{"spec":{"selector":{"app":"backend","version":"green"}}}'
```

#### Verify Switch
```bash
kubectl get svc backend-bg-service -n studentsphere \
  -o jsonpath='{.spec.selector}' && echo ""
```

Expected output:
```
{"app":"backend","version":"green"}
```

#### Rollback — Green to Blue
```bash
kubectl patch svc backend-bg-service -n studentsphere \
  -p '{"spec":{"selector":{"app":"backend","version":"blue"}}}'
```

### Output / Proof
![Blue-Green Switch](screenshots/phase5/02-blue-green-switch.png)

---

## 📸 All Deployments Running
![All Deployments](screenshots/phase5/03-all-deployments.png)

---

## 🆚 Deployment Strategy Comparison

| Strategy | Use Case | Downtime | Risk |
|---|---|---|---|
| Rolling Update | Normal updates | Zero | Medium |
| Canary | Test new version on small traffic | Zero | Low |
| Blue-Green | Instant switch with easy rollback | Zero | Very Low |
| Recreate | Simple apps, dev environments | Yes | High |

---

## 🐛 Troubleshooting

### Problem 1 — HPA Shows `<unknown>` Metrics
```
Error: cpu: <unknown>/70%

Root Cause: Metrics server not ready or pod resource requests not set

Fix:
kubectl get pods -n kube-system | grep metrics
# Wait 2-3 minutes for metrics to populate
```

### Problem 2 — HPA Keeps Scaling Up
```
Error: Too many pods created

Root Cause: Memory threshold too low for t3.small nodes

Fix: Increase memory threshold
averageUtilization: 95  # Instead of 80
```

### Problem 3 — Blue-Green Pods Pending
```
Error: 0/2 nodes available

Root Cause: t3.small nodes out of memory with too many pods

Fix: Scale down other deployments first
kubectl scale deployment backend --replicas=2 -n studentsphere
```

---

## 🔗 Related Repositories

| Repository | Purpose |
|---|---|
| [multi-cloud-devops-studentsphere](https://github.com/manesaurabh1704-devops/multi-cloud-devops-studentsphere) | Main project |
| [kubernetes-production-setup](https://github.com/manesaurabh1704-devops/kubernetes-production-setup) | All K8s manifests |
| [terraform-multi-cloud-infra](https://github.com/manesaurabh1704-devops/terraform-multi-cloud-infra) | Infrastructure as Code |
| [ci-cd-devops-pipelines](https://github.com/manesaurabh1704-devops/ci-cd-devops-pipelines) | Jenkins CI/CD |

---

## 👨‍💻 Author
**Saurabh Mane** — DevOps Engineer
- GitHub: [@manesaurabh1704-devops](https://github.com/manesaurabh1704-devops) 