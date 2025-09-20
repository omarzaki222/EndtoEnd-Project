# Docker Troubleshooting Guide for Jenkins

This guide helps you resolve Docker-related issues in your Jenkins pipeline.

## 🚨 Common Docker Issues

### 1. "docker: not found" Error

**Error Message:**
```
/var/jenkins_home/workspace/end-to-end-Project@tmp/durable-2a0803b1/script.sh.copy: 2: docker: not found
```

**Cause:** Docker is not installed or not accessible from Jenkins.

**Solutions:**

#### Option A: Install Docker on Jenkins Server

```bash
# Run the Docker installation script
sudo ./jenkins/install-docker.sh

# Restart Jenkins service
sudo systemctl restart jenkins
```

#### Option B: Manual Docker Installation

```bash
# Update package index
sudo apt-get update

# Install required packages
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index
sudo apt-get update

# Install Docker Engine
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add jenkins user to docker group
sudo usermod -aG docker jenkins

# Restart Jenkins
sudo systemctl restart jenkins
```

### 2. Docker Daemon Not Running

**Error Message:**
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Solution:**
```bash
# Start Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Check Docker status
sudo systemctl status docker
```

### 3. Permission Denied Error

**Error Message:**
```
permission denied while trying to connect to the Docker daemon socket
```

**Solution:**
```bash
# Add jenkins user to docker group
sudo usermod -aG docker jenkins

# Restart Jenkins service
sudo systemctl restart jenkins

# Verify permissions
sudo -u jenkins docker --version
```

## 🔧 Jenkins Configuration

### 1. Verify Docker Access

```bash
# Test Docker access as jenkins user
sudo -u jenkins docker --version
sudo -u jenkins docker info
sudo -u jenkins docker run hello-world
```

### 2. Check Jenkins Environment

```bash
# Check if Docker is in PATH
sudo -u jenkins which docker

# Check Docker socket permissions
ls -la /var/run/docker.sock

# Check if jenkins user is in docker group
groups jenkins
```

### 3. Jenkins System Information

In Jenkins UI:
1. Go to **Manage Jenkins** → **System Information**
2. Check for Docker-related environment variables
3. Verify PATH includes Docker binary location

## 🐳 Alternative Solutions

### 1. Use Docker-in-Docker (DinD)

If you can't install Docker directly on Jenkins, you can use Docker-in-Docker:

```groovy
pipeline {
    agent {
        docker {
            image 'docker:dind'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    // ... rest of pipeline
}
```

### 2. Use Remote Docker Host

Configure Jenkins to use a remote Docker host:

```bash
# Set Docker host environment variable
export DOCKER_HOST=tcp://remote-docker-host:2376

# Or configure in Jenkins system configuration
# Manage Jenkins → Configure System → Environment Variables
```

### 3. Use Jenkins Docker Plugin

Install the Docker Pipeline plugin:
1. Go to **Manage Jenkins** → **Manage Plugins**
2. Install **Docker Pipeline** plugin
3. Configure Docker in **Manage Jenkins** → **Configure System**

## 🧪 Testing Docker Setup

### 1. Test Docker Installation

```bash
# Check Docker version
docker --version

# Check Docker info
docker info

# Run test container
docker run hello-world
```

### 2. Test Jenkins Docker Access

```bash
# Test as jenkins user
sudo -u jenkins docker --version
sudo -u jenkins docker info
sudo -u jenkins docker run hello-world
```

### 3. Test Pipeline Locally

```bash
# Test the build script locally
cd /home/workernode2/pythonapp
./jenkins/build-and-push.sh test-tag 123
```

## 📋 Checklist

- [ ] Docker is installed on Jenkins server
- [ ] Docker service is running
- [ ] Jenkins user is in docker group
- [ ] Jenkins service has been restarted
- [ ] Docker is accessible from Jenkins workspace
- [ ] Docker credentials are configured in Jenkins
- [ ] Pipeline has proper error handling

## 🆘 Getting Help

If you're still experiencing issues:

1. **Check Jenkins logs:**
   ```bash
   sudo tail -f /var/log/jenkins/jenkins.log
   ```

2. **Check Docker logs:**
   ```bash
   sudo journalctl -u docker.service
   ```

3. **Verify system requirements:**
   - Ubuntu 20.04+ or similar Linux distribution
   - At least 2GB RAM
   - Docker-compatible kernel

4. **Test with minimal pipeline:**
   ```groovy
   pipeline {
       agent any
       stages {
           stage('Test Docker') {
               steps {
                   sh 'docker --version'
               }
           }
       }
   }
   ```

## 🔄 After Fixing Docker

Once Docker is properly installed and configured:

1. **Restart Jenkins:**
   ```bash
   sudo systemctl restart jenkins
   ```

2. **Test the pipeline:**
   - Go to Jenkins UI
   - Run your pipeline manually
   - Check the console output for Docker commands

3. **Verify the build:**
   - Check if Docker image is built successfully
   - Verify image is pushed to registry
   - Confirm manifests repository is updated

---

This guide should help you resolve Docker-related issues in your Jenkins pipeline. The most common solution is installing Docker and adding the jenkins user to the docker group.
