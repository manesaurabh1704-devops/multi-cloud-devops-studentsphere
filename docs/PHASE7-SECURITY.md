# Phase 7 — Security (Zero Trust Approach)

> RBAC + Network Policies + Trivy Image Scanning on AWS EKS.
> Part of [multi-cloud-devops-studentsphere](https://github.com/manesaurabh1704-devops/multi-cloud-devops-studentsphere)

---

## What is Zero Trust Security?

```
Traditional: Trust everything inside the cluster
Zero Trust:  Trust nothing — verify everything
```

Zero Trust means:
- Every pod has minimum required permissions only (RBAC)
- Every network connection is explicitly allowed (Network Policies)
- Every image is scanned for vulnerabilities before deployment (Trivy)

---

## Security Features Implemented

| Feature | Tool | Purpose |
|---|---|---|
| RBAC | Kubernetes RBAC | Control who can do what |
| Network Policies | Kubernetes NetworkPolicy | Control pod-to-pod communication |
| Image Scanning | Trivy | Detect vulnerabilities in Docker images |
| Secrets Management | Kubernetes Secrets | Secure DB credentials storage |

---

## Feature 1 — RBAC (Role-Based Access Control)

### What
RBAC controls which users and services can perform which actions on which resources in Kubernetes.

### Why
```
Without RBAC: Any pod can access any resource — secrets, configs, other pods
With RBAC:    Each pod has only minimum required permissions
```

### Architecture
```
ServiceAccount (Identity)
      ↓
Role (Permissions — what can be done)
      ↓
RoleBinding (Link SA to Role)
```

### How

```bash
kubectl apply -f k8s/aws/rbac.yaml
```

Resources created:
```yaml
# Backend ServiceAccount
apiVersion: v1
kind: ServiceAccount
metadata:
  name: backend-sa
  namespace: studentsphere

# Backend Role — can only read pods/services/secrets
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: backend-role
rules:
  - apiGroups: [""]
    resources: ["pods", "services", "endpoints"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get"]

# Frontend Role — can only read pods/services
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: frontend-role
rules:
  - apiGroups: [""]
    resources: ["pods", "services"]
    verbs: ["get", "list", "watch"]
```

### Verify RBAC

```bash
kubectl get serviceaccounts -n studentsphere
kubectl get roles -n studentsphere
kubectl get rolebindings -n studentsphere
```

Expected output:
```
NAME          SECRETS   AGE
backend-sa    0         1m
default       0         25h
frontend-sa   0         1m

NAME            CREATED AT
backend-role    2026-04-10T03:26:14Z
frontend-role   2026-04-10T03:26:14Z

NAME                   ROLE
backend-rolebinding    Role/backend-role
frontend-rolebinding   Role/frontend-role
```

### Output / Proof

#### RBAC Resources
![RBAC](../screenshots/phase7/01-rbac.png)

---

## Feature 2 — Network Policies

### What
Network Policies define which pods can communicate with which other pods — acting as a firewall inside the cluster.

### Why
```
Without Network Policy:
  frontend → mariadb directly (INSECURE!)
  Any pod → Any pod

With Network Policy:
  Internet → frontend (port 80 only)
  frontend → backend (port 8080 only)
  backend  → mariadb (port 3306 only)
  Everything else → BLOCKED
```

### Architecture
```
Internet
    ↓ (port 80 only)
Frontend Pods
    ↓ (port 8080 only)
Backend Pods
    ↓ (port 3306 only)
MariaDB
```

### How

```bash
kubectl apply -f k8s/aws/network-policy.yaml
```

Policies created:
```
default-deny-all          — Block all traffic by default
allow-frontend-ingress    — Allow internet → frontend (port 80)
allow-frontend-to-backend — Allow frontend → backend (port 8080)
allow-backend-to-mariadb  — Allow backend → mariadb (port 3306)
allow-dns                 — Allow DNS resolution (port 53)
```

### Verify Network Policies

```bash
kubectl get networkpolicies -n studentsphere
```

Expected output:
```
NAME                        POD-SELECTOR
allow-backend-to-mariadb    app=mariadb
allow-dns                   <none>
allow-frontend-ingress      app=frontend
allow-frontend-to-backend   app=backend
default-deny-all            <none>
```

### Output / Proof

#### Network Policies Applied
![Network Policies](../screenshots/phase7/02-network-policies.png)

---

## Feature 3 — Trivy Image Scanning

### What
Trivy scans Docker images for known security vulnerabilities (CVEs) before deployment.

### Why
```
Vulnerable image in production = Security breach risk
Trivy scan = Detect vulnerabilities early
CI/CD integration = Block deployment if CRITICAL found
```

### How

```bash
# Scan backend image
trivy image manesaurabh1704devops/studentsphere-backend:v1 \
  --severity HIGH,CRITICAL \
  --exit-code 0

# Scan frontend image
trivy image manesaurabh1704devops/studentsphere-frontend:v2 \
  --severity HIGH,CRITICAL \
  --exit-code 0
```

### Scan Results

#### Backend Image Results
```
Target: studentsphere-backend:v1 (ubuntu 22.04)
  Ubuntu OS:    0 vulnerabilities ✅

Target: app.jar
  Total: 12 (HIGH: 11, CRITICAL: 1)

  CRITICAL:
  - CVE-2025-24813: tomcat-embed-core 10.1.31
    Fix: upgrade to 10.1.35+

  HIGH (selected):
  - CVE-2024-50379: Tomcat RCE via JSP compilation
  - CVE-2025-22235: Spring Boot EndpointRequest matcher
  - CVE-2025-41249: Spring Framework annotation detection
```

#### Frontend Image Results
```
Target: studentsphere-frontend:v2 (alpine 3.19.1)
  Total: 20 (HIGH: 17, CRITICAL: 3)

  CRITICAL:
  - CVE-2024-45491: libexpat Integer Overflow
  - CVE-2024-45492: libexpat integer overflow
  - CVE-2024-56171: libxml2 Use-After-Free

  HIGH (selected):
  - CVE-2024-2398: curl HTTP/2 memory-leak
  - CVE-2024-6119: openssl X.509 DoS
  - CVE-2025-24928: libxml2 stack overflow
```

### Remediation Plan

| Image | Issue | Fix |
|---|---|---|
| Backend | Tomcat 10.1.31 | Upgrade Spring Boot to 3.4.x |
| Frontend | Alpine 3.19.1 | Upgrade to Alpine 3.20+ |
| Frontend | nginx 1.25 | Upgrade to nginx 1.27+ |

### Output / Proof

#### Backend Trivy Scan
![Backend Scan](../screenshots/phase7/03-trivy-backend-scan.png)

#### Frontend Trivy Scan
![Frontend Scan](../screenshots/phase7/04-trivy-frontend-scan.png)

---

## Feature 4 — Kubernetes Secrets

### What
Kubernetes Secrets store sensitive data (passwords, tokens) separately from application code.

### Why
```
Without Secrets: Passwords hardcoded in yaml files (INSECURE!)
With Secrets:    Passwords stored encrypted in etcd — injected at runtime
```

### How

```yaml
# secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
  namespace: studentsphere
type: Opaque
stringData:
  DB_NAME: student_db
  DB_USER: student
  DB_PASS: student123
  DB_URL: jdbc:mariadb://mariadb-service:3306/student_db
```

```bash
kubectl apply -f k8s/aws/secrets.yaml
kubectl get secrets -n studentsphere
```

---

## Security Summary

| Security Layer | Status | Tool |
|---|---|---|
| Pod Identity | ✅ Implemented | RBAC ServiceAccounts |
| Access Control | ✅ Implemented | RBAC Roles + RoleBindings |
| Network Firewall | ✅ Implemented | Network Policies |
| Secret Management | ✅ Implemented | Kubernetes Secrets |
| Image Scanning | ✅ Implemented | Trivy |
| Image Remediation | ⏳ Pending | Upgrade base images |

---

## Troubleshooting

### Problem 1 — Network Policy Blocks App Traffic
```
Error: App not accessible after network policy applied

Fix: Check if allow-frontend-ingress policy exists
kubectl get networkpolicies -n studentsphere
kubectl describe networkpolicy allow-frontend-ingress -n studentsphere
```

### Problem 2 — Trivy Cannot Pull Image
```
Error: failed to pull image

Fix: Login to DockerHub first
docker login
trivy image your-image:tag
```

### Problem 3 — RBAC Permission Denied
```
Error: pods is forbidden: User cannot list pods

Fix: Check role has correct verbs
kubectl describe role backend-role -n studentsphere
```

---

## Related Repositories

| Repository | Purpose |
|---|---|
| [multi-cloud-devops-studentsphere](https://github.com/manesaurabh1704-devops/multi-cloud-devops-studentsphere) | Main project |
| [kubernetes-production-setup](https://github.com/manesaurabh1704-devops/kubernetes-production-setup) | K8s manifests |
| [devops-security-secrets](https://github.com/manesaurabh1704-devops/devops-security-secrets) | Security configs |

---

## Author
**Saurabh Mane** — DevOps Engineer
- GitHub: [@manesaurabh1704-devops](https://github.com/manesaurabh1704-devops)

---

> ⭐ Star this repo if you find it helpful!