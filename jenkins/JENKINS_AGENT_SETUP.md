# Jenkins Agent Setup Guide

## Overview
This guide sets up workernode2 as a Jenkins agent with Docker and kubectl access for a clean, reliable CI/CD pipeline.

## Prerequisites
- ✅ Docker is installed and accessible
- ✅ kubectl is installed and configured
- ❌ Java needs to be installed

## Step 1: Install Java

```bash
# Install OpenJDK 11 (recommended)
sudo apt update && sudo apt install -y openjdk-11-jdk

# Or install OpenJDK 17
sudo apt update && sudo apt install -y openjdk-17-jdk

# Verify installation
java -version
```

## Step 2: Create Jenkins Agent Node

### Option A: Using Jenkins Web UI (Recommended)

1. **Open Jenkins Web UI**
   - Go to: `http://your-jenkins-server:8080`

2. **Navigate to Node Management**
   - Click: `Manage Jenkins` → `Manage Nodes and Clouds`

3. **Create New Node**
   - Click: `New Node`
   - Node name: `workernode2-agent`
   - Type: `Permanent Agent`
   - Click: `OK`

4. **Configure Node Settings**
   ```
   Remote root directory: /home/workernode2/jenkins-agent
   Labels: docker kubectl ubuntu
   Usage: Use this node as much as possible
   Launch method: Launch agent by connecting it to the master
   ```

5. **Save Configuration**
   - Click: `Save`

### Option B: Using Jenkins CLI

```bash
# Download Jenkins CLI
wget http://your-jenkins-server:8080/jnlpJars/jenkins-cli.jar

# Create the agent node
java -jar jenkins-cli.jar -s http://your-jenkins-server:8080 create-node workernode2-agent << 'NODE_CONFIG'
<?xml version='1.1' encoding='UTF-8'?>
<slave>
  <name>workernode2-agent</name>
  <description>Ubuntu agent with Docker and kubectl access</description>
  <remoteFS>/home/workernode2/jenkins-agent</remoteFS>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <launcher class="hudson.slaves.JNLPLauncher">
    <workDirSettings>
      <disabled>false</disabled>
      <workDirPath></workDirPath>
      <internalDir>remoting</internalDir>
      <failIfWorkDirIsMissing>false</failIfWorkDirIsMissing>
    </workDirSettings>
    <webSocket>false</webSocket>
    <credentialsId></credentialsId>
  </launcher>
  <label>docker kubectl ubuntu</label>
  <nodeProperties>
    <hudson.slaves.EnvironmentVariablesNodeProperty>
      <envVars>
        <hudson.slaves.EnvironmentVariablesNodeProperty$Entry>
          <key>DOCKER_HOST</key>
          <value>unix:///var/run/docker.sock</value>
        </hudson.slaves.EnvironmentVariablesNodeProperty$Entry>
        <hudson.slaves.EnvironmentVariablesNodeProperty$Entry>
          <key>KUBECONFIG</key>
          <value>/home/workernode2/.kube/config</value>
        </hudson.slaves.EnvironmentVariablesNodeProperty$Entry>
      </envVars>
    </hudson.slaves.EnvironmentVariablesNodeProperty>
  </nodeProperties>
</slave>
NODE_CONFIG
```

## Step 3: Start Jenkins Agent

1. **Get Agent Connection Details**
   - Go to the agent node page in Jenkins
   - Copy the connection command

2. **Create Agent Directory**
   ```bash
   mkdir -p ~/jenkins-agent
   cd ~/jenkins-agent
   ```

3. **Download Agent JAR**
   ```bash
   wget http://your-jenkins-server:8080/jnlpJars/agent.jar
   ```

4. **Start Agent**
   ```bash
   # Replace with your actual command from Jenkins
   java -jar agent.jar -jnlpUrl http://your-jenkins-server:8080/computer/workernode2-agent/slave-agent.jnlp -secret YOUR_SECRET
   ```

## Step 4: Update Jenkinsfile

Replace the current Jenkinsfile with the agent-optimized version:

```bash
cp Jenkinsfile-agent Jenkinsfile
git add Jenkinsfile
git commit -m "Update Jenkinsfile to use Ubuntu agent with Docker and kubectl"
git push origin main
```

## Step 5: Test the Pipeline

1. **Run a Jenkins Build**
   - Go to your Jenkins job
   - Click "Build with Parameters"
   - Use these settings:
     - IMAGE_TAG: `latest`
     - ENVIRONMENT: `dev`
     - SKIP_TESTS: `false`

2. **Verify Agent Usage**
   - Check that the build runs on `workernode2-agent`
   - Verify Docker build works
   - Confirm kubectl operations work

## Benefits of This Setup

### ✅ **Advantages**
- **Direct Docker Access**: No need for Kaniko or complex workarounds
- **kubectl Integration**: Direct Kubernetes operations
- **Better Performance**: Dedicated resources for builds
- **Easier Debugging**: Can SSH into agent to troubleshoot
- **Standard Practice**: Follows industry best practices
- **Simpler Pipeline**: Clean, straightforward Jenkinsfile

### 🔧 **What This Eliminates**
- ❌ Complex Kaniko setups
- ❌ External processing scripts
- ❌ kubectl access issues
- ❌ Container limitations
- ❌ Workaround solutions

## Troubleshooting

### Agent Connection Issues
```bash
# Check Java installation
java -version

# Check network connectivity
ping your-jenkins-server

# Check firewall
sudo ufw status
```

### Docker Issues
```bash
# Check Docker daemon
sudo systemctl status docker

# Check user permissions
groups $USER

# Test Docker access
docker run hello-world
```

### kubectl Issues
```bash
# Check kubectl configuration
kubectl config view

# Test cluster access
kubectl cluster-info

# Check kubeconfig file
ls -la ~/.kube/config
```

## Next Steps

1. **Install Java** on workernode2
2. **Create Jenkins agent node** in Jenkins UI
3. **Start the agent** with the provided command
4. **Update Jenkinsfile** to use the agent
5. **Test the complete pipeline**

This setup will provide a much more reliable and maintainable CI/CD pipeline! 🚀
