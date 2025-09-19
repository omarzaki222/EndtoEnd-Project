# End-to-End Python Flask Application

A complete Python Flask application with CI/CD pipeline using Jenkins and Kubernetes deployment.

## 🚀 Features

- **Flask Web Application**: Simple web application with templating
- **Docker Containerization**: Multi-stage Docker build for production
- **Kubernetes Deployment**: Complete K8s manifests with ConfigMaps, Services, and Ingress
- **Jenkins CI/CD Pipeline**: Automated build, test, and deployment pipeline
- **Persistent Storage**: PVC and PV configuration for data persistence
- **Health Checks**: Liveness and readiness probes for container health

## 📁 Project Structure

```
pythonapp/
├── app/                          # Flask application source code
│   ├── main.py                   # Main Flask application
│   ├── requirements.txt          # Python dependencies
│   └── templates/                # HTML templates
├── mainfest/                     # Kubernetes manifests
│   ├── namespace.yaml           # Namespace configuration
│   ├── configmap.yaml           # Application configuration
│   ├── pv.yaml                  # Persistent Volume
│   ├── pvc.yaml                 # Persistent Volume Claim
│   ├── deployment.yaml          # Application deployment
│   ├── service.yaml             # Service configuration
│   ├── ingress.yaml             # Ingress configuration
│   └── kustomization.yaml       # Kustomize configuration
├── jenkins/                      # Jenkins pipeline files
│   ├── pipeline-config.xml      # Jenkins job configuration
│   ├── deploy.sh                # Deployment script
│   └── build-and-push.sh        # Docker build and push script
├── Dockerfile                    # Docker container configuration
├── Jenkinsfile                   # Jenkins pipeline definition
├── requirements.txt              # Python dependencies
└── README.md                     # This file
```

## 🛠️ Prerequisites

- **Docker**: For containerization
- **Kubernetes**: For orchestration (v1.30.13)
- **Jenkins**: For CI/CD pipeline
- **kubectl**: Kubernetes command-line tool
- **Git**: For version control

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd pythonapp
```

### 2. Build and Run Locally

```bash
# Build Docker image
docker build -t end-to-end-app .

# Run container
docker run -p 8000:8000 end-to-end-app
```

### 3. Deploy to Kubernetes

```bash
# Apply all manifests
kubectl apply -f mainfest/

# Check deployment status
kubectl get pods -n flask-app
kubectl get svc -n flask-app
```

### 4. Access the Application

```bash
# Get service details
kubectl get svc end-to-end-service -n flask-app

# Port forward for local access
kubectl port-forward svc/end-to-end-service 8000:8000 -n flask-app
```

## 🔧 Jenkins Pipeline Setup

### Required Jenkins Plugins

- Pipeline
- Docker Pipeline
- Kubernetes CLI
- Git

### Required Credentials

1. **Docker Hub Credentials** (`docker-hub-credentials`)
   - Username: Your Docker Hub username
   - Password: Your Docker Hub password/token

2. **Kubernetes Config** (`kubeconfig`)
   - Upload your kubeconfig file

3. **GitHub Credentials** (`github-credentials`)
   - Username: Your GitHub username
   - Password: Your GitHub personal access token

### Pipeline Configuration

1. Create a new Pipeline job in Jenkins
2. Configure the pipeline to use the `Jenkinsfile` from SCM
3. Set up the required credentials
4. Configure webhook triggers (optional)

### Pipeline Stages

1. **Checkout**: Clone the repository
2. **Build Docker Image**: Build and tag the Docker image
3. **Run Tests**: Execute application tests (optional)
4. **Push to Registry**: Push image to Docker Hub
5. **Deploy to Kubernetes**: Deploy to K8s cluster
6. **Health Check**: Verify deployment success

## 🐳 Docker Configuration

The application uses a multi-stage Docker build:

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ app/
EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app.main:app", "--workers", "2", "--timeout", "120"]
```

## ☸️ Kubernetes Configuration

### Namespace
- **flask-app**: Isolated namespace for the application

### Resources
- **ConfigMap**: Application configuration
- **PersistentVolume**: Storage for application data
- **PersistentVolumeClaim**: Storage claim
- **Deployment**: Application deployment with 1 replica
- **Service**: NodePort service for external access
- **Ingress**: HTTP routing (optional)

### Resource Limits
- **Memory**: 128Mi request, 256Mi limit
- **CPU**: 100m request, 200m limit

## 🔄 CI/CD Pipeline

The Jenkins pipeline supports:

- **Multi-environment deployment** (dev, staging, prod)
- **Automatic image tagging** with Git commit hash
- **Rolling deployments** with health checks
- **Build artifact management**
- **Notification on success/failure**

### Pipeline Parameters

- `IMAGE_TAG`: Docker image tag (default: latest)
- `ENVIRONMENT`: Deployment environment (dev/staging/prod)
- `SKIP_TESTS`: Skip running tests (default: false)

## 📊 Monitoring and Health Checks

### Health Probes

- **Liveness Probe**: HTTP GET on `/` every 10 seconds
- **Readiness Probe**: HTTP GET on `/` every 5 seconds

### Monitoring Commands

```bash
# Check pod status
kubectl get pods -n flask-app -l app=end-to-end-app

# Check service endpoints
kubectl get endpoints -n flask-app

# View application logs
kubectl logs -f deployment/end-to-end-app -n flask-app

# Check resource usage
kubectl top pods -n flask-app
```

## 🔧 Configuration

### Environment Variables

- `APP_ENV`: Application environment (production)
- `LOG_LEVEL`: Logging level (INFO)
- `FLASK_ENV`: Flask environment (production)

### Customization

1. **Update Docker image**: Modify `Dockerfile`
2. **Change resource limits**: Edit `mainfest/deployment.yaml`
3. **Modify pipeline**: Update `Jenkinsfile`
4. **Add new environments**: Update pipeline parameters

## 🚨 Troubleshooting

### Common Issues

1. **Pod not starting**:
   ```bash
   kubectl describe pod <pod-name> -n flask-app
   kubectl logs <pod-name> -n flask-app
   ```

2. **Service not accessible**:
   ```bash
   kubectl get svc -n flask-app
   kubectl get endpoints -n flask-app
   ```

3. **Pipeline failures**:
   - Check Jenkins logs
   - Verify credentials are configured
   - Ensure Docker and kubectl are available

### Debug Commands

```bash
# Check cluster connectivity
kubectl cluster-info

# Verify namespace exists
kubectl get namespaces

# Check persistent volumes
kubectl get pv,pvc -n flask-app

# View all resources
kubectl get all -n flask-app
```

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the pipeline
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review Jenkins and Kubernetes logs
