# Jenkins Pipeline Configuration

This directory contains Jenkins-specific configuration files and scripts for the End-to-End Python Flask Application CI/CD pipeline.

## 📁 Files Overview

### `pipeline-config.xml`
Jenkins job configuration file that can be imported to create a new pipeline job.

**Features:**
- Automatic SCM polling every 5 minutes
- Build retention policy (7 days, 10 builds)
- Git integration with branch support
- Clean checkout configuration

### `deploy.sh`
Deployment script that handles Kubernetes deployment operations.

**Usage:**
```bash
./deploy.sh [environment] [image_tag]
```

**Parameters:**
- `environment`: Target environment (dev, staging, prod) - default: dev
- `image_tag`: Docker image tag to deploy - default: latest

**Features:**
- Namespace creation
- Image tag updates
- Rolling deployment
- Health checks
- Deployment verification

### `build-and-push.sh`
Docker build and push script for container registry operations.

**Usage:**
```bash
./build-and-push.sh [image_tag]
```

**Parameters:**
- `image_tag`: Docker image tag - default: latest

**Features:**
- Docker image building
- Multi-tag support
- Registry authentication
- Push operations

## 🔧 Jenkins Setup Instructions

### 1. Install Required Plugins

Ensure the following Jenkins plugins are installed:

- **Pipeline** (`workflow-aggregator`)
- **Docker Pipeline** (`docker-workflow`)
- **Kubernetes CLI** (`kubernetes-cli`)
- **Git** (`git`)
- **Credentials Binding** (`credentials-binding`)

### 2. Configure Credentials

Create the following credentials in Jenkins:

#### Docker Hub Credentials
- **ID**: `docker-hub-credentials`
- **Type**: Username with password
- **Username**: Your Docker Hub username
- **Password**: Your Docker Hub password or access token

#### Kubernetes Configuration
- **ID**: `kubeconfig`
- **Type**: Secret file
- **File**: Upload your kubeconfig file

#### GitHub Credentials (if using GitHub)
- **ID**: `github-credentials`
- **Type**: Username with password
- **Username**: Your GitHub username
- **Password**: Your GitHub personal access token

### 3. Create Pipeline Job

#### Option A: Import Configuration
1. Create a new Pipeline job
2. Go to "Configure"
3. Copy the contents of `pipeline-config.xml`
4. Update the repository URL in the configuration
5. Save the job

#### Option B: Manual Configuration
1. Create a new Pipeline job
2. Configure SCM to point to your Git repository
3. Set the script path to `Jenkinsfile`
4. Configure build triggers (polling or webhooks)
5. Set up build retention policies

### 4. Configure Build Environment

Ensure Jenkins has access to:
- Docker daemon
- kubectl command
- Git repository
- Container registry

### 5. Test the Pipeline

1. Trigger a manual build
2. Monitor the pipeline execution
3. Check logs for any issues
4. Verify deployment in Kubernetes

## 🚀 Pipeline Execution

### Manual Execution
```bash
# Trigger pipeline with default parameters
curl -X POST http://jenkins-url/job/your-job-name/build

# Trigger with parameters
curl -X POST http://jenkins-url/job/your-job-name/buildWithParameters \
  -d "IMAGE_TAG=v1.0.0&ENVIRONMENT=staging&SKIP_TESTS=false"
```

### Webhook Integration
Configure webhooks in your Git repository to trigger builds automatically:

**GitHub Webhook URL:**
```
http://jenkins-url/github-webhook/
```

**GitLab Webhook URL:**
```
http://jenkins-url/project/your-job-name
```

## 🔍 Pipeline Monitoring

### Build Status
- **Blue**: Success
- **Red**: Failed
- **Yellow**: Unstable
- **Gray**: Aborted/Not built

### Log Analysis
```bash
# View build logs
curl http://jenkins-url/job/your-job-name/lastBuild/consoleText

# View specific stage logs
curl http://jenkins-url/job/your-job-name/lastBuild/execution/node/3/ws/log
```

### Metrics and Reports
- Build duration trends
- Success/failure rates
- Deployment frequency
- Resource utilization

## 🛠️ Troubleshooting

### Common Issues

#### 1. Docker Build Failures
```bash
# Check Docker daemon status
docker info

# Verify Dockerfile syntax
docker build --no-cache -t test-image .
```

#### 2. Kubernetes Deployment Issues
```bash
# Check cluster connectivity
kubectl cluster-info

# Verify namespace exists
kubectl get namespaces

# Check resource availability
kubectl top nodes
```

#### 3. Credential Issues
- Verify credential IDs match pipeline configuration
- Check credential permissions
- Ensure credentials are not expired

#### 4. Pipeline Script Errors
- Validate Jenkinsfile syntax
- Check Groovy script compatibility
- Review Jenkins console output

### Debug Commands

```bash
# Test Docker build locally
./jenkins/build-and-push.sh test-tag

# Test Kubernetes deployment
./jenkins/deploy.sh dev test-tag

# Check Jenkins agent connectivity
ssh jenkins-agent "docker --version && kubectl version"
```

## 📊 Best Practices

### Security
- Use Jenkins credentials store
- Implement least privilege access
- Regular credential rotation
- Secure pipeline scripts

### Performance
- Use Docker layer caching
- Parallel stage execution
- Resource optimization
- Build artifact cleanup

### Reliability
- Implement retry mechanisms
- Health check validation
- Rollback procedures
- Monitoring and alerting

### Maintenance
- Regular plugin updates
- Pipeline script reviews
- Documentation updates
- Backup procedures

## 🔄 Pipeline Customization

### Adding New Stages
1. Update `Jenkinsfile`
2. Add corresponding scripts if needed
3. Update documentation
4. Test thoroughly

### Environment-Specific Configurations
1. Create environment-specific ConfigMaps
2. Update deployment scripts
3. Configure environment variables
4. Test in each environment

### Integration with External Tools
1. Add webhook configurations
2. Update notification settings
3. Configure monitoring tools
4. Set up logging aggregation
