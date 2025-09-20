#!/bin/bash

# Monitor Jenkins builds and process them automatically
# This script watches for new Jenkins builds and processes them

set -e

JENKINS_WORKSPACE="/var/jenkins_home/workspace/end-to-end-Project"
PROCESS_SCRIPT="/home/workernode2/pythonapp/jenkins/process-jenkins-build.sh"

echo "🔍 Monitoring Jenkins builds..."
echo "Jenkins workspace: ${JENKINS_WORKSPACE}"
echo "Process script: ${PROCESS_SCRIPT}"

# Check if process script exists
if [ ! -f "$PROCESS_SCRIPT" ]; then
    echo "❌ Process script not found: ${PROCESS_SCRIPT}"
    exit 1
fi

# Make sure process script is executable
chmod +x "$PROCESS_SCRIPT"

echo "✅ Monitoring started. Waiting for Jenkins builds..."
echo "Press Ctrl+C to stop monitoring"

# Monitor for build-info.txt files
while true; do
    if [ -f "${JENKINS_WORKSPACE}/build-info.txt" ]; then
        echo ""
        echo "🚀 New Jenkins build detected!"
        echo "Processing build..."
        
        # Process the build
        "$PROCESS_SCRIPT" "$JENKINS_WORKSPACE"
        
        # Wait a bit before checking again
        sleep 10
    else
        # Wait before checking again
        sleep 5
    fi
done
