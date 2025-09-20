#!/bin/bash

# Setup Jenkins Agent on workernode2
# This script sets up workernode2 as a Jenkins agent with Docker and kubectl access

set -e

echo "🚀 Setting up Jenkins Agent on workernode2"
echo "=========================================="

# Check current user and permissions
echo "Current user: $(whoami)"
echo "User groups: $(groups)"

# Check if required tools are available
echo ""
echo "🔍 Checking required tools..."

if command -v docker &> /dev/null; then
    echo "✅ Docker is available: $(docker --version)"
else
    echo "❌ Docker is not available"
    exit 1
fi

if command -v kubectl &> /dev/null; then
    echo "✅ kubectl is available: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
else
    echo "❌ kubectl is not available"
    exit 1
fi

if command -v java &> /dev/null; then
    echo "✅ Java is available: $(java -version 2>&1 | head -1)"
else
    echo "❌ Java is not available - needs to be installed"
    echo ""
    echo "📋 To install Java, run:"
    echo "sudo apt update && sudo apt install -y openjdk-11-jdk"
    echo ""
    echo "Or if you prefer OpenJDK 17:"
    echo "sudo apt update && sudo apt install -y openjdk-17-jdk"
    echo ""
    read -p "Press Enter after installing Java, or Ctrl+C to exit..."
fi

# Check Docker access
echo ""
echo "🔍 Testing Docker access..."
if docker info &> /dev/null; then
    echo "✅ Docker daemon is accessible"
else
    echo "❌ Cannot access Docker daemon"
    echo "You may need to start Docker service:"
    echo "sudo systemctl start docker"
    echo "sudo systemctl enable docker"
fi

# Check kubectl access
echo ""
echo "🔍 Testing kubectl access..."
if kubectl cluster-info &> /dev/null; then
    echo "✅ Kubernetes cluster is accessible"
    echo "Cluster info:"
    kubectl cluster-info --request-timeout=5s
else
    echo "❌ Cannot access Kubernetes cluster"
    echo "Please ensure kubectl is configured with proper kubeconfig"
fi

# Create Jenkins agent directory
echo ""
echo "📁 Setting up Jenkins agent directory..."
mkdir -p ~/jenkins-agent
cd ~/jenkins-agent

# Download Jenkins agent JAR (this will be done manually)
echo ""
echo "📥 To complete the setup, you need to:"
echo "1. Go to Jenkins Web UI"
echo "2. Navigate to: Manage Jenkins → Manage Nodes and Clouds"
echo "3. Click 'New Node'"
echo "4. Enter node name: 'workernode2-agent'"
echo "5. Select 'Permanent Agent'"
echo "6. Configure the node:"
echo "   - Remote root directory: /home/workernode2/jenkins-agent"
echo "   - Launch method: 'Launch agent by connecting it to the master'"
echo "   - Save the configuration"
echo "7. Download the agent JAR file from the node page"
echo "8. Run the agent with the provided command"

echo ""
echo "🔧 Alternative: Use Jenkins CLI to create the agent"
echo "=================================================="
echo ""
echo "If you have Jenkins CLI available, you can create the agent with:"
echo ""
cat << 'EOF'
java -jar jenkins-cli.jar -s http://your-jenkins-url:8080 create-node workernode2-agent << 'NODE_CONFIG'
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
EOF

echo ""
echo "🎯 After setting up the agent:"
echo "1. The Jenkinsfile will be updated to use this agent"
echo "2. Docker builds will work directly (no Kaniko needed)"
echo "3. kubectl operations will work directly"
echo "4. The pipeline will be much simpler and more reliable"
echo ""
echo "✅ Setup script completed!"
