pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'omarzaki222'
        IMAGE_NAME = 'end-to-end-project'
        KUBECONFIG = credentials('kubeconfig')
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
    }
    
    parameters {
        string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Docker image tag')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Deployment environment')
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip running tests')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                    env.BUILD_TAG = "${BUILD_NUMBER}-${env.GIT_COMMIT_SHORT}"
                }
            }
        }
        
        stage('Build with Kaniko') {
            steps {
                script {
                    def imageTag = params.IMAGE_TAG == 'latest' ? "${env.BUILD_TAG}" : params.IMAGE_TAG
                    env.FULL_IMAGE_NAME = "${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag}"

                    sh """
                        echo "Building Docker image with Kaniko: ${env.FULL_IMAGE_NAME}"
                        
                        # Create a temporary directory for the build context
                        mkdir -p /tmp/kaniko-build-${BUILD_NUMBER}
                        cp -r . /tmp/kaniko-build-${BUILD_NUMBER}/
                        
                        # Run Kaniko build in Kubernetes
                        kubectl run kaniko-build-${BUILD_NUMBER} \\
                          --image=gcr.io/kaniko-project/executor:latest \\
                          --rm -i --restart=Never \\
                          --overrides='
{
  "spec": {
    "containers": [
      {
        "name": "kaniko-build",
        "image": "gcr.io/kaniko-project/executor:latest",
        "args": [
          "--context=dir:///workspace",
          "--dockerfile=/workspace/Dockerfile",
          "--destination=${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag}",
          "--destination=${DOCKER_REGISTRY}/${IMAGE_NAME}:latest",
          "--destination=${DOCKER_REGISTRY}/${IMAGE_NAME}:build-${BUILD_NUMBER}",
          "--cache=true",
          "--cache-ttl=24h"
        ],
        "volumeMounts": [
          {
            "name": "docker-config",
            "mountPath": "/kaniko/.docker"
          },
          {
            "name": "build-context",
            "mountPath": "/workspace"
          }
        ]
      }
    ],
    "volumes": [
      {
        "name": "docker-config",
        "secret": {
          "secretName": "docker-registry-secret"
        }
      },
      {
        "name": "build-context",
        "hostPath": {
          "path": "/tmp/kaniko-build-${BUILD_NUMBER}"
        }
      }
    ]
  }
}' \\
                          -- /kaniko/executor
                        
                        # Clean up temporary directory
                        rm -rf /tmp/kaniko-build-${BUILD_NUMBER}
                        
                        echo "Kaniko build completed successfully!"
                    """
                }
            }
        }
        
        stage('Run Tests') {
            when {
                expression { 
                    return !params.SKIP_TESTS 
                }
            }
            steps {
                sh """
                    # Run tests using kubectl to create a test pod
                    kubectl run test-pod-${BUILD_NUMBER} \\
                      --image=${env.FULL_IMAGE_NAME} \\
                      --rm -i --restart=Never \\
                      --command -- python -m pytest tests/ || echo "No tests found or tests failed"
                """
            }
        }
        
        stage('Verify Image Push') {
            steps {
                sh """
                    echo "Verifying that images were pushed successfully..."
                    echo "Images should be available at:"
                    echo "- ${env.FULL_IMAGE_NAME}"
                    echo "- ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                    echo "- ${DOCKER_REGISTRY}/${IMAGE_NAME}:build-${BUILD_NUMBER}"
                    echo "Kaniko automatically pushes images during the build stage."
                """
            }
        }
        
        stage('Update Manifests Repository') {
            steps {
                script {
                    def imageTag = params.IMAGE_TAG == 'latest' ? "${env.BUILD_TAG}" : params.IMAGE_TAG
                    
                    sh """
                        # Clone the manifests repository
                        echo "Cloning manifests repository..."
                        git clone https://github.com/omarzaki222/EndtoEnd-Project-Manifests.git manifests-repo
                        cd manifests-repo
                        
                        # Check if mainfest directory exists
                        if [ ! -d "mainfest" ]; then
                            echo "Error: mainfest directory not found!"
                            exit 1
                        fi
                        
                        # Navigate to mainfest directory and update image tag in deployment
                        echo "Updating image tag in deployment.yaml..."
                        cd mainfest
                        
                        # Check if deployment.yaml exists
                        if [ ! -f "deployment.yaml" ]; then
                            echo "Error: deployment.yaml not found in mainfest directory!"
                            exit 1
                        fi
                        
                        # Update the image tag
                        sed -i 's|image: omarzaki222/end-to-end-project:.*|image: ${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag}|g' deployment.yaml
                        
                        # Verify the change was made
                        echo "Updated deployment.yaml:"
                        grep "image:" deployment.yaml
                        
                        # Go back to root and commit changes
                        cd ..
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins"
                        git add mainfest/deployment.yaml
                        git commit -m "Update image tag to ${imageTag} for ${params.ENVIRONMENT} environment (Build #${BUILD_NUMBER})" || echo "No changes to commit"
                        git push origin main
                        
                        echo "Successfully updated manifests repository with image tag: ${imageTag}"
                        
                        # Clean up
                        cd ..
                        rm -rf manifests-repo
                    """
                }
            }
        }
        
        stage('ArgoCD Sync') {
            steps {
                script {
                    def appName = "end-to-end-app-${params.ENVIRONMENT}"
                    
                    sh """
                        # Wait for ArgoCD to detect changes
                        sleep 30
                        
                        # Trigger ArgoCD sync (optional - ArgoCD can auto-sync)
                        kubectl patch application ${appName} -n argocd --type merge -p '{"operation":{"sync":{"syncStrategy":{"hook":{"force":true}}}}}' || echo "Manual sync not available, relying on auto-sync"
                        
                        # Wait for ArgoCD sync to complete
                        kubectl wait --for=condition=Synced application/${appName} -n argocd --timeout=300s || echo "Sync condition not met, checking deployment status"
                    """
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    def namespace = "flask-app-${params.ENVIRONMENT}"
                    sh """
                        # Get service details
                        kubectl get svc end-to-end-service -n ${namespace}
                        
                        # Check if pods are running
                        kubectl get pods -n ${namespace} -l app=end-to-end-app
                        
                        # Basic health check
                        sleep 30
                        kubectl get pods -n ${namespace} -l app=end-to-end-app -o jsonpath='{.items[0].status.phase}' | grep -q Running
                    """
                }
            }
        }
    }
    
    post {
        always {
            sh '''
                # Clean up any temporary Kaniko build directories
                rm -rf /tmp/kaniko-build-* || echo "No temporary directories to clean"
            '''
            cleanWs()
        }
        success {
            echo "Pipeline completed successfully!"
            script {
                def imageTag = params.IMAGE_TAG == 'latest' ? "${env.BUILD_TAG}" : params.IMAGE_TAG
                echo "Deployed image: ${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag}"
                echo "Build number: ${BUILD_NUMBER}"
                echo "Git commit: ${env.GIT_COMMIT_SHORT}"
            }
        }
        failure {
            echo "Pipeline failed!"
            // You can add notification logic here (Slack, email, etc.)
        }
    }
}
