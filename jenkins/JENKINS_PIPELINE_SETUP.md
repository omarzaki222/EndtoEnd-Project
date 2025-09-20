# Jenkins Pipeline Setup Guide

## 🎉 **Jenkins is Running Successfully!**

### **Access Information:**
- **URL**: `http://192.168.0.103:8080`
- **Admin Password**: `066a5ee2229c4ffb8ac15b75ae2090cf`

## 🚀 **Next Steps:**

### **1. Complete Jenkins Initial Setup**
1. **Access Jenkins** at `http://192.168.0.103:8080`
2. **Enter admin password**: `066a5ee2229c4ffb8ac15b75ae2090cf`
3. **Install suggested plugins** (recommended)
4. **Create admin user** (optional but recommended)
5. **Configure Jenkins URL** (keep default)

### **2. Configure Credentials**
Go to **Manage Jenkins** → **Manage Credentials** → **Add credentials**:

#### **Docker Hub Credentials:**
- **Kind**: Username with password
- **ID**: `docker-hub-credentials`
- **Username**: Your Docker Hub username
- **Password**: Your Docker Hub password

#### **GitHub Token:**
- **Kind**: Secret text
- **ID**: `github-token`
- **Secret**: Your GitHub personal access token

### **3. Create Pipeline Job**
1. Click **"New Item"**
2. Enter name: `end-to-end-project`
3. Select **"Pipeline"**
4. Click **"OK"**
5. In Pipeline section:
   - **Definition**: `Pipeline script from SCM`
   - **SCM**: `Git`
   - **Repository URL**: `https://github.com/omarzaki222/EndtoEnd-Project.git`
   - **Branch**: `*/main`
   - **Script Path**: `Jenkinsfile`

### **4. Test Your Pipeline**
1. Go to your pipeline job
2. Click **"Build Now"**
3. Watch the build progress
4. Check the console output

## ✅ **What's Fixed:**

- **Agent Issue**: Changed from `label 'docker kubectl ubuntu'` to `agent any`
- **Docker Access**: Now uses Docker directly on the Ubuntu machine
- **Simplified Pipeline**: Removed Kaniko complexity, uses standard Docker build
- **Direct Access**: Jenkins runs directly on Ubuntu with Docker and kubectl

## 🎯 **Pipeline Features:**

- ✅ **Docker Build**: Builds images directly on Ubuntu machine
- ✅ **Docker Push**: Pushes to Docker Hub with credentials
- ✅ **Git Integration**: Pulls from GitHub repository
- ✅ **Manifests Update**: Updates Kubernetes manifests repository
- ✅ **ArgoCD Integration**: Triggers ArgoCD sync
- ✅ **Health Checks**: Verifies deployment status

## 🔧 **Troubleshooting:**

### **If Pipeline Fails:**
1. **Check credentials** are configured correctly
2. **Verify Docker** is running: `docker version`
3. **Check kubectl** access: `kubectl get nodes`
4. **Review console output** for specific errors

### **Common Issues:**
- **Docker not found**: Ensure Docker is installed and running
- **kubectl not found**: Ensure kubectl is installed and configured
- **Permission denied**: Check file permissions and user groups

## 🚀 **You're Ready to Go!**

Your Jenkins server is now properly configured and ready to run your CI/CD pipeline! The pipeline will:

1. **Checkout** code from GitHub
2. **Build** Docker image with build number tag
3. **Push** to Docker Hub
4. **Update** Kubernetes manifests
5. **Trigger** ArgoCD deployment
6. **Verify** deployment health

**Happy building! 🎉**
