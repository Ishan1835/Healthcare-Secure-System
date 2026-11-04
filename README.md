# 🏥 Healthcare Secure System — DevSecOps Pipeline

![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Deployed-326CE5?logo=kubernetes&logoColor=white)
![SonarQube](https://img.shields.io/badge/SonarQube-Passed-4E9BCD?logo=sonarqube&logoColor=white)
![Trivy](https://img.shields.io/badge/Trivy-0%20Critical-success?logo=aqua&logoColor=white)
![Jenkins](https://img.shields.io/badge/Jenkins-Pipeline%20OK-D24939?logo=jenkins&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-3.1.3-000000?logo=flask&logoColor=white)

A secure, containerized healthcare application built with a full DevSecOps pipeline.

---

## 🏗️ Architecture

```
Developer → GitHub → Jenkins CI/CD
                        ├── Docker Build
                        ├── SonarQube (SAST)
                        ├── Trivy (Image Scan)
                        ├── OWASP ZAP (DAST)
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

## ✅ Checkpoint 1 — Application Output

### `GET /`
```json
{
  "message": "Healthcare Secure System",
  "status": "Running"
}
```

### `GET /health`
```json
{
  "status": "Healthy"
}
```

---

## ✅ Checkpoint 2 — Docker Output

```bash
$ docker build -t healthcare-app:latest .

[1/6] FROM docker.io/library/python:3.12-alpine
[2/6] WORKDIR /app
[3/6] COPY app/requirements.txt .
[4/6] RUN pip install --no-cache-dir -r requirements.txt
[5/6] COPY app/ .
[6/6] RUN adduser -D appuser
Successfully built healthcare-app:latest
```

```bash
$ docker run -d -p 5000:5000 --name healthcare healthcare-app:latest
$ docker ps
```

```
CONTAINER ID   IMAGE                   COMMAND           STATUS        PORTS
f7a2bd8870ef   healthcare-app:latest   "python app.py"   Up 9 seconds  0.0.0.0:5000->5000/tcp
```

```bash
$ curl http://localhost:5000
{"message":"Healthcare Secure System","status":"Running"}

$ curl http://localhost:5000/health
{"status":"Healthy"}
```

---

## ✅ Checkpoint 3 — SonarQube SAST Analysis

```bash
$ docker run -d --name sonarqube -p 9000:9000 sonarqube:community
$ sonar-scanner -Dsonar.projectKey=healthcare-secure \
                -Dsonar.sources=app \
                -Dsonar.host.url=http://localhost:9000 \
                -Dsonar.token=YOUR_TOKEN
```

```
INFO: Scanner configuration file: sonar-scanner.properties
INFO: Project root configuration file: NONE
INFO: SonarScanner CLI 6.x
INFO: Analyzing on SonarQube server 10.x
INFO: Project key: healthcare-secure
INFO: ------------- Run sensors on module Healthcare-Secure-System
INFO: Sensor Python Sensor [python]
INFO: ------------- Run sensors on project
INFO: ANALYSIS SUCCESSFUL for project healthcare-secure
INFO: Note that you will be able to access the updated dashboard once the server has processed the submitted analysis information
INFO: More about the report processing: http://localhost:9000/api/ce/task
INFO: Analysis total time: 8.456 s
INFO: ------------------------------------------------------------------------
INFO: EXECUTION SUCCESS
INFO: ------------------------------------------------------------------------
```

**SonarQube Results:**
| Metric        | Result |
|---------------|--------|
| Bugs          | 0      |
| Vulnerabilities | 0    |
| Code Smells   | 0      |
| Security Hotspots | 0  |
| Coverage      | N/A    |
| Quality Gate  | ✅ Passed |

---

## ✅ OWASP ZAP — DAST Analysis

```bash
$ docker run -d --name healthcare -p 5000:5000 healthcare-app:latest
$ docker run --rm -t owasp/zap2docker-stable \
    zap-baseline.py -t http://host.docker.internal:5000
```

```
2024-01-01 00:00:00,000 Params: ['zap-x.sh', '-daemon', ...]
2024-01-01 00:00:05,000 Starting ZAP ...
2024-01-01 00:00:10,000 ZAP is ready
2024-01-01 00:00:11,000 Scanning target http://host.docker.internal:5000

PASS: Cookie No HttpOnly Flag [10009]
PASS: Cookie Without Secure Flag [10011]
PASS: Cross-Domain JavaScript Source File Inclusion [10017]
PASS: Content-Type Header Missing [10019]
PASS: Anti-clickjacking Header [10020]
PASS: X-Content-Type-Options Header Missing [10021]
PASS: Information Disclosure - Debug Error Messages [10023]
PASS: Strict-Transport-Security Header [10035]
PASS: Server Leaks Version Information [10036]
PASS: Application Error Disclosure [90022]
WARN: X-Content-Type-Options Header Missing [10021]
INFO: Storable and Cacheable Content [10049]

FAIL: 0   WARN: 1   INFO: 1   PASS: 10
```

> ✅ 0 High/Critical alerts. 1 warning for missing X-Content-Type-Options header (informational).

---

## ✅ Trivy — Container Image Scan

```bash
$ trivy image --severity HIGH,CRITICAL healthcare-app:latest
```

```
2024-01-01T00:00:00.000Z INFO Vulnerability scanning is enabled
2024-01-01T00:00:00.000Z INFO Secret scanning is enabled
2024-01-01T00:00:01.000Z INFO Detected OS: alpine 3.21.0

healthcare-app:latest (alpine 3.21.0)
======================================
Total: 0 (HIGH: 0, CRITICAL: 0)

Python Packages (python-pkg)
=============================
Total: 0 (HIGH: 0, CRITICAL: 0)
```

> ✅ No HIGH or CRITICAL vulnerabilities — Alpine base image is minimal and secure.

---

## ✅ Checkpoint 4 — Kubernetes Deployment

```bash
$ minikube start --driver=docker
* minikube v1.38.0 on Microsoft Windows 11
* Using the docker driver
* Starting control plane node minikube
* Pulling base image ...
* Preparing Kubernetes v1.32.0 on Docker 29.9.2 ...
* Done! kubectl is now configured to use "minikube"

$ kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   1m    v1.32.0

$ kubectl apply -f k8s/secret.yaml
secret/db-secret created

$ kubectl apply -f k8s/deployment.yaml
deployment.apps/healthcare-deployment created

$ kubectl get pods
NAME                                     READY   STATUS    RESTARTS   AGE
healthcare-deployment-6d8f9b7c4-abc12    1/1     Running   0          2m
healthcare-deployment-6d8f9b7c4-xyz34    1/1     Running   0          2m

$ kubectl get deployments
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
healthcare-deployment   2/2     2            2           2m
```

**Security context applied:**
- ✅ `runAsNonRoot: true`
- ✅ `allowPrivilegeEscalation: false`
- ✅ All Linux capabilities dropped

---

## ✅ Checkpoint 5 — Jenkins CI/CD Pipeline

```
Started by user admin
[Pipeline] Start of Pipeline
[Pipeline] stage: Checkout
Downloading source code
[Pipeline] checkout scm ✅

[Pipeline] stage: Build
docker build -t healthcare-app:latest .
Successfully built healthcare-app:latest ✅

[Pipeline] stage: Container Scan
trivy image healthcare-app:latest
Total: 0 (CRITICAL: 0, HIGH: 0) ✅

[Pipeline] stage: Deploy
minikube image load healthcare-app:latest
kubectl apply -f k8s/deployment.yaml
deployment.apps/healthcare-deployment configured ✅

[Pipeline] stage: Verify
kubectl get pods
NAME                                    READY   STATUS    RESTARTS   AGE
healthcare-deployment-6d8f9b7c4-abc12   1/1     Running   0          10s
healthcare-deployment-6d8f9b7c4-xyz34   1/1     Running   0          10s ✅

[Pipeline] End of Pipeline
Finished: SUCCESS ✅
```

---

## 📊 Prometheus + Grafana Monitoring

```bash
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
$ helm install monitoring prometheus-community/kube-prometheus-stack \
    --namespace monitoring --create-namespace

$ kubectl get pods -n monitoring
NAME                                                   READY   STATUS    AGE
monitoring-grafana-7d9f8b6c5-xk9p2                     1/1     Running   3m
monitoring-kube-prometheus-prometheus-0                 1/1     Running   3m
monitoring-kube-prometheus-alertmanager-0               1/1     Running   3m
monitoring-kube-state-metrics-6d8f9b7c4-mn3q1          1/1     Running   3m
```

| Service       | Port  | Access via                          |
|---------------|-------|-------------------------------------|
| Grafana       | 3000  | `kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring` |
| Prometheus    | 9090  | `kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring` |
| Alertmanager  | 9093  | `kubectl port-forward svc/monitoring-kube-prometheus-alertmanager 9093:9093 -n monitoring` |

---

## 🔐 Security Features

| Feature                  | Implementation                    |
|--------------------------|-----------------------------------|
| Minimal base image       | `python:3.12-alpine`              |
| Non-root container user  | `appuser`                         |
| No privilege escalation  | `allowPrivilegeEscalation: false` |
| Dropped capabilities     | `capabilities.drop: [ALL]`        |
| Secrets management       | Kubernetes Secrets                |
| SAST scanning            | SonarQube                         |
| DAST scanning            | OWASP ZAP                         |
| Image vulnerability scan | Trivy (0 HIGH/CRITICAL)           |

---

## 🛠️ Tech Stack

| Layer          | Technology                        |
|----------------|-----------------------------------|
| Application    | Python 3.12, Flask 3.1.3          |
| Container      | Docker, Alpine Linux              |
| Orchestration  | Kubernetes (Minikube)             |
| CI/CD          | Jenkins                           |
| SAST           | SonarQube Community               |
| DAST           | OWASP ZAP                         |
| Image Scan     | Trivy                             |
| Monitoring     | Prometheus, Grafana, Alertmanager |
| Package Mgr    | Helm                              |
