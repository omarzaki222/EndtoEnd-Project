# Jenkins Setup Guide

This guide will help you set up Jenkins for your End-to-End Python Flask Application CI/CD pipeline.

## 🔧 Prerequisites

- Jenkins server running (version 2.400+)
- Docker installed and running
- kubectl configured and accessible
- Git installed
- Access to Docker Hub registry

## 📦 Required Jenkins Plugins

Install the following plugins in Jenkins:

1. **Pipeline** (`workflow-aggregator`)
2. **Docker Pipeline** (`docker-workflow`)
3. **Kubernetes CLI** (`kubernetes-cli`)
4. **Git** (`git`)
5. **Credentials Binding** (`credentials-binding`)
6. **GitHub Integration** (`github`)

## 🔐 Configure Credentials

### 1. Docker Hub Credentials

1. Go to **Manage Jenkins** → **Manage Credentials**
2. Select **System** → **Global credentials**
3. Click **Add Credentials**
4. Configure:
   - **Kind**: Username with password
   - **ID**: `docker-hub-credentials`
   - **Username**: Your Docker Hub username
   - **Password**: Your Docker Hub password or access token
   - **Description**: Docker Hub credentials for image push

### 2. Kubernetes Configuration

1. Go to **Manage Jenkins** → **Manage Credentials**
2. Select **System** → **Global credentials**
3. Click **Add Credentials**
4. Configure:
   - **Kind**: Secret file
   - **ID**: `kubeconfig`
   - **File**: Upload your kubeconfig file
   - **Description**: Kubernetes cluster configuration

### 3. GitHub Credentials (Optional)

1. Go to **Manage Jenkins** → **Manage Credentials**
2. Select **System** → **Global credentials**
3. Click **Add Credentials**
4. Configure:
   - **Kind**: Username with password
   - **ID**: `github-credentials`
   - **Username**: Your GitHub username
   - **Password**: Your GitHub personal access token
   - **Description**: GitHub credentials for repository access

## 🚀 Create Pipeline Job

### Method 1: Using Jenkins UI

1. **Create New Job**
   - Go to Jenkins dashboard
   - Click **New Item**
   - Enter job name: `end-to-end-python-app`
   - Select **Pipeline**
   - Click **OK**

2. **Configure Pipeline**
   - **General**:
     - ✅ GitHub project
     - Project url: `https://github.com/YOUR_USERNAME/YOUR_REPO_NAME`
   - **Build Triggers**:
     - ✅ GitHub hook trigger for GITScm polling
     - ✅ Poll SCM: `H/5 * * * *` (every 5 minutes)
   - **Pipeline**:
     - **Definition**: Pipeline script from SCM
     - **SCM**: Git
     - **Repository URL**: `https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git`
     - **Credentials**: Select `github-credentials`
     - **Branch**: `*/main`
     - **Script Path**: `Jenkinsfile`

3. **Save Configuration**

### Method 2: Import Configuration

1. Create a new Pipeline job
2. Go to **Configure**
3. Replace the configuration with the contents of `jenkins/pipeline-config.xml`
4. Update the repository URL
5. Save the job

## 🧪 Test the Pipeline

### 1. Manual Build

1. Go to your pipeline job
2. Click **Build with Parameters**
3. Configure parameters:
   - **IMAGE_TAG**: `test-1.0.0`
   - **ENVIRONMENT**: `dev`
   - **SKIP_TESTS**: `false`
4. Click **Build**

### 2. Monitor Build

1. Click on the build number
2. Click **Console Output** to view logs
3. Monitor each stage:
   - Checkout
   - Build Docker Image
   - Run Tests
   - Push to Registry
   - Deploy to Kubernetes
   - Health Check

### 3. Verify Deployment

```bash
# Check if pods are running
kubectl get pods -n flask-app

# Check service
kubectl get svc -n flask-app

# Check deployment status
kubectl rollout status deployment/end-to-end-app -n flask-app
```

## 🔄 Webhook Configuration (Optional)

### GitHub Webhook

1. Go to your GitHub repository
2. Click **Settings** → **Webhooks**
3. Click **Add webhook**
4. Configure:
   - **Payload URL**: `http://your-jenkins-url/github-webhook/`
   - **Content type**: `application/json`
   - **Events**: ✅ Pushes
   - **Active**: ✅

### GitLab Webhook

1. Go to your GitLab project
2. Click **Settings** → **Webhooks**
3. Configure:
   - **URL**: `http://your-jenkins-url/project/end-to-end-python-app`
   - **Trigger**: ✅ Push events
   - **SSL verification**: ✅

## 🛠️ Troubleshooting

### Common Issues

#### 1. Docker Build Failures

**Error**: `Cannot connect to the Docker daemon`

**Solution**:
```bash
# Add jenkins user to docker group
sudo usermod -aG docker jenkins

# Restart Jenkins
sudo systemctl restart jenkins
```

#### 2. Kubernetes Connection Issues

**Error**: `Unable to connect to the server`

**Solution**:
- Verify kubeconfig file is correct
- Check if kubectl is installed on Jenkins agent
- Ensure Jenkins has access to the Kubernetes cluster

#### 3. Credential Issues

**Error**: `Credentials not found`

**Solution**:
- Verify credential IDs match pipeline configuration
- Check if credentials are in the correct scope (Global)
- Ensure credentials are not expired

#### 4. Permission Issues

**Error**: `Permission denied`

**Solution**:
```bash
# Check Jenkins user permissions
sudo -u jenkins kubectl get nodes

# Fix file permissions
sudo chown -R jenkins:jenkins /var/lib/jenkins/workspace/
```

### Debug Commands

```bash
# Test Docker access
sudo -u jenkins docker info

# Test kubectl access
sudo -u jenkins kubectl cluster-info

# Check Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# Check pipeline workspace
ls -la /var/lib/jenkins/workspace/end-to-end-python-app/
```

## 📊 Monitoring and Maintenance

### Build Retention

Configure build retention in your pipeline:
- **Days to keep builds**: 7
- **Max # of builds to keep**: 10
- **Days to keep artifacts**: 7

### Performance Optimization

1. **Use Docker layer caching**
2. **Parallel stage execution**
3. **Resource optimization**
4. **Build artifact cleanup**

### Security Best Practices

1. **Use Jenkins credentials store**
2. **Implement least privilege access**
3. **Regular credential rotation**
4. **Secure pipeline scripts**
5. **Enable CSRF protection**

## 🔄 Pipeline Customization

### Adding New Environments

1. Update pipeline parameters
2. Create environment-specific ConfigMaps
3. Update deployment scripts
4. Test in each environment

### Adding New Stages

1. Update `Jenkinsfile`
2. Add corresponding scripts
3. Update documentation
4. Test thoroughly

### Integration with External Tools

1. **Slack notifications**
2. **Email notifications**
3. **Monitoring tools**
4. **Log aggregation**

## 📞 Support

If you encounter issues:

1. Check Jenkins console output
2. Review Kubernetes logs
3. Verify credentials and permissions
4. Check network connectivity
5. Review this troubleshooting guide

For additional help, create an issue in the repository or consult the Jenkins documentation.
