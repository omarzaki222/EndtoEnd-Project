# End-to-End Python Flask Application with Complete CI/CD Pipeline

A comprehensive Python Flask application with full CI/CD pipeline using Jenkins, Docker, Kubernetes, and ArgoCD GitOps deployment.

## 🚀 Features

- **Flask Web Application**: Simple web application with templating
- **Docker Containerization**: Multi-stage Docker build for production
- **Kubernetes Deployment**: Complete K8s manifests with ConfigMaps, Services, and Ingress
- **Jenkins CI/CD Pipeline**: Automated build, test, and deployment pipeline
- **ArgoCD GitOps**: GitOps-based continuous deployment with ArgoCD
- **Multi-Environment Support**: Dev, staging, and production environments
- **Persistent Storage**: PVC and PV configuration for data persistence
- **Health Checks**: Liveness and readiness probes for container health
- **Ubuntu Jenkins Server**: Jenkins running directly on Ubuntu with Docker and kubectl access

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
├── jenkins/                      # Jenkins pipeline and setup files
│   ├── Jenkinsfile              # Main Jenkins pipeline
│   ├── Jenkinsfile-agent        # Agent-based Jenkins pipeline
│   ├── install-jenkins-ubuntu.sh # Jenkins installation script
│   ├── fix-jenkins-java.sh      # Java version fix script
│   ├── fix-docker-permissions.sh # Docker permissions fix
│   ├── update-manifests.sh      # Manifests update script
│   ├── build-and-push.sh        # Docker build and push script
│   ├── kaniko-build.sh          # Kaniko build script
│   ├── process-jenkins-build.sh # External build processor
│   ├── monitor-jenkins-builds.sh # Build monitor script
│   ├── setup-github-credentials.sh # GitHub credentials setup
│   ├── JENKINS_PIPELINE_SETUP.md # Pipeline setup guide
│   ├── JENKINS_ACCESS_FIX.md    # Access troubleshooting
│   ├── MANUAL_JENKINS_INSTALL.md # Manual installation guide
│   └── DOCKER_TROUBLESHOOTING.md # Docker troubleshooting
├── argocd/                       # ArgoCD GitOps configuration
│   ├── application.yaml         # Main ArgoCD application
│   ├── application-dev.yaml     # Development environment
│   ├── application-staging.yaml # Staging environment
│   ├── application-prod.yaml    # Production environment
│   ├── install-argocd.sh        # ArgoCD installation script
│   └── setup-applications.sh    # Application setup script
├── Dockerfile                    # Docker container configuration
├── .dockerignore                # Docker ignore file
├── .gitignore                   # Git ignore file
├── env.example                  # Environment variables template
├── env.local                    # Local environment variables (not committed)
├── setup-env.sh                 # Environment setup script
├── setup-github.sh              # GitHub repository setup
├── setup-credentials.sh         # Credentials setup guide
├── README.md                    # This file
├── ARGOCD_SETUP.md             # ArgoCD setup guide
├── JENKINS_SETUP.md            # Jenkins setup guide
└── PROJECT_NOTES.md            # Comprehensive project notes
```

## 🛠️ Prerequisites

- **Ubuntu Machine**: For Jenkins server (workernode2)
- **Docker**: For containerization
- **Kubernetes**: For orchestration (v1.30.13)
- **Jenkins**: For CI/CD pipeline (installed on Ubuntu)
- **kubectl**: Kubernetes command-line tool
- **Git**: For version control
- **Java 17+**: Required for Jenkins

## 🚀 Complete Setup Guide

### 1. Environment Setup

#### Clone and Configure Repository
```bash
# Clone the repository
git clone https://github.com/omarzaki222/EndtoEnd-Project.git
cd EndtoEnd-Project

# Set up environment variables
cp env.example env.local
# Edit env.local with your actual credentials
```

#### Configure Environment Variables (`env.local`)
```bash
# Docker Hub Configuration
DOCKER_USERNAME=your_dockerhub_username
DOCKER_PASSWORD=your_dockerhub_password
DOCKER_REGISTRY=your_dockerhub_username

# GitHub Configuration
GITHUB_USERNAME=your_github_username
GITHUB_TOKEN=your_github_token

# Application Configuration
APP_ENV=production
LOG_LEVEL=INFO
FLASK_ENV=production
```

### 2. Jenkins Server Installation

#### Install Jenkins on Ubuntu
```bash
# Update system
sudo apt update

# Install Java 17 (required for Jenkins)
sudo apt install -y openjdk-17-jdk

# Add Jenkins repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt update
sudo apt install -y jenkins

# Start and enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

#### Configure Jenkins for Network Access
```bash
# Edit Jenkins configuration
sudo nano /etc/default/jenkins

# Add --httpListenAddress=0.0.0.0 to JENKINS_ARGS
JENKINS_ARGS="--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT --httpListenAddress=0.0.0.0"

# Restart Jenkins
sudo systemctl restart jenkins
```

#### Fix Docker Permissions
```bash
# Add Jenkins user to docker group
sudo usermod -aG docker jenkins

# Alternative: Fix Docker socket permissions
sudo chmod 666 /var/run/docker.sock

# Restart Jenkins
sudo systemctl restart jenkins
```

### 3. Jenkins Initial Setup

#### Access Jenkins
- **URL**: `http://YOUR_IP:8080`
- **Initial Password**: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

#### Complete Jenkins Setup
1. **Enter initial admin password**
2. **Install suggested plugins**
3. **Create admin user**
4. **Configure Jenkins URL** (keep default)

### 4. Configure Jenkins Credentials

Go to **Manage Jenkins** → **Manage Credentials** → **Add credentials**:

#### Docker Hub Credentials
- **Kind**: Username with password
- **ID**: `docker-hub-credentials`
- **Username**: Your Docker Hub username
- **Password**: Your Docker Hub password

#### GitHub Token
- **Kind**: Secret text
- **ID**: `github-token`
- **Secret**: Your GitHub personal access token

### 5. Create Jenkins Pipeline Job

1. **Click "New Item"**
2. **Enter name**: `end-to-end-project`
3. **Select "Pipeline"**
4. **Click "OK"**
5. **In Pipeline section**:
   - **Definition**: `Pipeline script from SCM`
   - **SCM**: `Git`
   - **Repository URL**: `https://github.com/omarzaki222/EndtoEnd-Project.git`
   - **Branch**: `*/main`
   - **Script Path**: `Jenkinsfile`

#### Automatic Pipeline Triggers
The pipeline is configured with automatic SCM polling:
- **Trigger**: `pollSCM('H/5 * * * *')` - checks every 5 minutes
- **Automatic Build**: Runs when code changes are detected
- **Default Parameters**: Uses `dev` environment and `latest` tag

### 6. Set Up Separate Manifests Repository

#### Create Manifests Repository
```bash
# Clone the manifests repository
git clone https://github.com/omarzaki222/EndtoEnd-Project-Manifests.git
cd EndtoEnd-Project-Manifests

# Copy manifests from main repository
cp -r ../EndtoEnd-Project/mainfest ./
cp -r ../EndtoEnd-Project/argocd ./

# Commit and push
git add .
git commit -m "Initial manifests setup"
git push origin main
```

### 7. ArgoCD Setup (Optional)

#### Install ArgoCD
```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Access ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Open: https://localhost:8080
```

#### Create ArgoCD Applications
```bash
# Apply ArgoCD applications
kubectl apply -f argocd/application.yaml
kubectl apply -f argocd/application-dev.yaml
kubectl apply -f argocd/application-staging.yaml
kubectl apply -f argocd/application-prod.yaml
```

## 🔄 CI/CD Pipeline Flow

### Automatic Workflow
1. **Code Push** → GitHub repository
2. **SCM Polling** → Jenkins detects changes (every 5 minutes)
3. **Automatic Build** → Pipeline runs with default parameters
4. **Build Docker Image** → Build with build number tag
5. **Run Tests** → Execute application tests (optional)
6. **Update Manifests Repository** → Update image tag in manifests
7. **ArgoCD Sync** → Automatic deployment
8. **Health Check** → Verify deployment success

### Pipeline Stages

1. **Checkout**: Clone code from GitHub
2. **Build Docker Image**: Build with build number tag
3. **Run Tests**: Execute application tests (optional)
4. **Update Manifests Repository**: Update image tag in manifests
5. **ArgoCD Sync**: Trigger ArgoCD deployment
6. **Health Check**: Verify deployment success

### Pipeline Features

- **Automatic Triggers**: SCM polling every 5 minutes
- **Automatic Image Tagging**: Uses build number and Git commit hash
- **Multi-Environment Support**: Dev, staging, production
- **GitOps Integration**: Updates manifests repository
- **Health Monitoring**: Verifies deployment status
- **Rollback Capability**: Easy rollback through ArgoCD

### Pipeline Parameters

- `IMAGE_TAG`: Docker image tag (default: latest)
- `ENVIRONMENT`: Deployment environment (dev/staging/prod)
- `SKIP_TESTS`: Skip running tests (default: false)

## 🐳 Docker Configuration

### Multi-stage Docker Build
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ app/
EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app.main:app", "--workers", "2", "--timeout", "120"]
```

### Image Tagging Strategy
- **Build Tag**: `BUILD_NUMBER-GIT_COMMIT_SHORT`
- **Latest**: `latest`
- **Build Specific**: `build-BUILD_NUMBER`

## ☸️ Kubernetes Configuration

### Namespace Structure
- **flask-app-dev**: Development environment
- **flask-app-staging**: Staging environment
- **flask-app-prod**: Production environment

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

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. Jenkins Agent Issues
**Problem**: `'Jenkins' doesn't have label 'docker kubectl ubuntu'`
**Solution**: Use `agent any` in Jenkinsfile

#### 2. Docker Permission Denied
**Problem**: `permission denied while trying to connect to the Docker daemon socket`
**Solution**:
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
# OR
sudo chmod 666 /var/run/docker.sock
```

#### 3. Java Version Issues
**Problem**: `Running with Java 11, which is older than the minimum required version (Java 17)`
**Solution**:
```bash
sudo apt install -y openjdk-17-jdk
sudo update-alternatives --config java
```

#### 4. Jenkins Access Issues
**Problem**: Cannot access Jenkins from external machine
**Solution**:
```bash
# Edit Jenkins configuration
sudo nano /etc/default/jenkins
# Add --httpListenAddress=0.0.0.0
sudo systemctl restart jenkins
```

### Debug Commands

```bash
# Check Jenkins status
sudo systemctl status jenkins

# Check Docker permissions
sudo -u jenkins docker version

# Check kubectl access
kubectl get nodes

# Check Jenkins logs
sudo journalctl -u jenkins -f

# Check Docker daemon
docker version
```

## 📊 Monitoring and Health Checks

### Health Probes
- **Liveness Probe**: HTTP GET on `/` every 10 seconds
- **Readiness Probe**: HTTP GET on `/` every 5 seconds

### Monitoring Commands
```bash
# Check pod status
kubectl get pods -n flask-app-dev -l app=end-to-end-app

# Check service endpoints
kubectl get endpoints -n flask-app-dev

# View application logs
kubectl logs -f deployment/end-to-end-app -n flask-app-dev

# Check resource usage
kubectl top pods -n flask-app-dev
```

## 🎯 Access Information

### Jenkins
- **URL**: `http://192.168.0.103:8080`
- **Admin Password**: `066a5ee2229c4ffb8ac15b75ae2090cf`

### Application
- **Development**: `http://YOUR_CLUSTER_IP:30080`
- **Staging**: `http://YOUR_CLUSTER_IP:30081`
- **Production**: `http://YOUR_CLUSTER_IP:30082`

### ArgoCD
- **URL**: `https://localhost:8080` (with port-forward)
- **Username**: `admin`
- **Password**: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

## 📝 Project Evolution

### What We Built
1. **Complete Flask Application** with Docker containerization
2. **Kubernetes Manifests** for multi-environment deployment
3. **Jenkins CI/CD Pipeline** with automated builds and deployments
4. **ArgoCD GitOps** for continuous deployment
5. **Ubuntu Jenkins Server** with Docker and kubectl access
6. **Separate Manifests Repository** for GitOps workflow
7. **Comprehensive Documentation** and troubleshooting guides

### Key Achievements
- ✅ **Full CI/CD Pipeline** from code to production
- ✅ **Multi-Environment Support** (dev, staging, prod)
- ✅ **GitOps Workflow** with ArgoCD
- ✅ **Automated Image Tagging** with build numbers
- ✅ **Health Monitoring** and rollback capabilities
- ✅ **Complete Documentation** and setup guides

## 🆘 Support

For support and questions:
- Check the troubleshooting section above
- Review Jenkins and Kubernetes logs
- Consult the comprehensive guides in the `jenkins/` directory
- Create an issue in the repository

## 📄 License

This project is licensed under the MIT License.