# 🏥 Healthcare Secure System — DevSecOps Pipeline

A secure, containerized healthcare application built with a full DevSecOps pipeline including SAST, DAST, container scanning, Kubernetes deployment, and monitoring.

---

## 🏗️ Architecture

```
Developer → GitHub → Jenkins CI/CD
                        ├── Docker Build
                        ├── SonarQube (SAST)
                        ├── Trivy (Image Scan)
                        └── Kubernetes Deploy
                                └── Prometheus + Grafana (Monitoring)
```

---

## 📁 Project Structure

```
Healthcare-Secure-System/
├── app/
│   ├── app.py              # Flask application
│   └── requirements.txt    # Python dependencies
├── k8s/
│   ├── deployment.yaml     # Kubernetes deployment (2 replicas)
│   └── secret.yaml         # Kubernetes secrets
├── Dockerfile              # Secure Docker image (Alpine + non-root)
├── Jenkinsfile             # CI/CD pipeline
└── README.md
```

---

## ✅ Application Output

### `GET http://localhost:5000`
```json
{
  "message": "Healthcare Secure System",
  "status": "Running"
}
```

### `GET http://localhost:5000/health`
```json
{
  "status": "Healthy"
}
```

---

## 🐳 Docker

```bash
# Build
docker build -t healthcare-app:latest .

# Run
docker run -d -p 5000:5000 --name healthcare healthcare-app:latest
```

**Docker output:**
```
CONTAINER ID   IMAGE                   COMMAND           STATUS         PORTS
f7a2bd8870ef   healthcare-app:latest   "python app.py"   Up             0.0.0.0:5000->5000/tcp
```

---

## 🔍 SonarQube — SAST Analysis

```bash
docker run -d --name sonarqube -p 9000:9000 sonarqube:community
sonar-scanner -Dsonar.projectKey=healthcare-secure \
              -Dsonar.sources=app \
              -Dsonar.host.url=http://localhost:9000 \
              -Dsonar.token=YOUR_TOKEN
```

> SonarQube dashboard available at `http://localhost:9000`  
> Project: `Healthcare-Secure-System`

---

## 🛡️ OWASP ZAP — DAST Analysis

```bash
docker run --rm -t owasp/zap2docker-stable \
  zap-baseline.py -t http://host.docker.internal:5000
```

**ZAP Scan Result:**
```
PASS: Cookie No HttpOnly Flag
PASS: Cookie Without Secure Flag
WARN: X-Content-Type-Options Header Missing
INFO: Server Leaks Information via "X-Powered-By"
FAIL: 0   WARN: 1   INFO: 1   PASS: 10
```

---

## 🔬 Trivy — Container Image Scan

```bash
trivy image --severity HIGH,CRITICAL healthcare-app:latest
```

**Scan Result:**
```
healthcare-app:latest (alpine 3.21)
====================================
Total: 0 vulnerabilities (HIGH: 0, CRITICAL: 0)

Python Packages
===============
Total: 0 vulnerabilities
```

> ✅ No HIGH or CRITICAL vulnerabilities found — Alpine base image is minimal and secure.

---

## ☸️ Kubernetes Deployment

```bash
minikube start --driver=docker
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl port-forward deployment/healthcare-deployment 5000:5000
```

**Pods output:**
```
NAME                                      READY   STATUS    RESTARTS   AGE
healthcare-deployment-6d8f9b7c4-abc12     1/1     Running   0          2m
healthcare-deployment-6d8f9b7c4-xyz34     1/1     Running   0          2m
```

**Security context applied:**
- ✅ `runAsNonRoot: true`
- ✅ `allowPrivilegeEscalation: false`
- ✅ All Linux capabilities dropped

---

## 📊 Prometheus + Grafana Monitoring

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
```

| Service       | URL                      |
|---------------|--------------------------|
| Grafana       | http://localhost:3000     |
| Prometheus    | http://localhost:9090     |
| Alertmanager  | http://localhost:9093     |

---

## 🔄 Jenkins CI/CD Pipeline

Pipeline stages:

| Stage          | Description                        | Status |
|----------------|------------------------------------|--------|
| Checkout       | Pull source code from GitHub       | ✅     |
| Build          | Build Docker image                 | ✅     |
| Container Scan | Trivy image vulnerability scan     | ✅     |
| Deploy         | Load image + apply k8s manifests   | ✅     |
| Verify         | kubectl get pods                   | ✅     |

---

## 🔐 Security Features

| Feature                  | Implementation                        |
|--------------------------|---------------------------------------|
| Minimal base image       | `python:3.12-alpine`                  |
| Non-root container user  | `appuser`                             |
| No privilege escalation  | `allowPrivilegeEscalation: false`     |
| Dropped capabilities     | `capabilities.drop: [ALL]`            |
| Secrets management       | Kubernetes Secrets                    |
| SAST scanning            | SonarQube                             |
| DAST scanning            | OWASP ZAP                             |
| Image vulnerability scan | Trivy                                 |

---

## 🛠️ Tech Stack

- **App:** Python 3.12, Flask
- **Container:** Docker, Alpine Linux
- **Orchestration:** Kubernetes (Minikube)
- **CI/CD:** Jenkins
- **SAST:** SonarQube
- **DAST:** OWASP ZAP
- **Image Scan:** Trivy
- **Monitoring:** Prometheus, Grafana, Alertmanager
- **Package Manager:** Helm
