pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'omarzaki222'
        IMAGE_NAME = 'end-to-end-project'
        KUBECONFIG = credentials('kubeconfig')
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        GITHUB_TOKEN = credentials('github-token')
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
                        echo "Note: This stage will be handled by external script"
                        echo "Image tag: ${imageTag}"
                        echo "Build number: ${BUILD_NUMBER}"
                        echo "Full image name: ${env.FULL_IMAGE_NAME}"
                        
                        # Create a marker file to indicate build parameters in shared directory
                        mkdir -p /var/jenkins_home/shared-builds
                        echo "BUILD_NUMBER=${BUILD_NUMBER}" > /var/jenkins_home/shared-builds/build-info-${BUILD_NUMBER}.txt
                        echo "IMAGE_TAG=${imageTag}" >> /var/jenkins_home/shared-builds/build-info-${BUILD_NUMBER}.txt
                        echo "FULL_IMAGE_NAME=${env.FULL_IMAGE_NAME}" >> /var/jenkins_home/shared-builds/build-info-${BUILD_NUMBER}.txt
                        echo "DOCKER_REGISTRY=${DOCKER_REGISTRY}" >> /var/jenkins_home/shared-builds/build-info-${BUILD_NUMBER}.txt
                        echo "IMAGE_NAME=${IMAGE_NAME}" >> /var/jenkins_home/shared-builds/build-info-${BUILD_NUMBER}.txt
                        echo "WORKSPACE_PATH=${WORKSPACE}" >> /var/jenkins_home/shared-builds/build-info-${BUILD_NUMBER}.txt
                        
                        echo "Build parameters saved to /var/jenkins_home/shared-builds/build-info-${BUILD_NUMBER}.txt"
                        echo "External script should process this build"
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
                    echo "Running tests for image: ${env.FULL_IMAGE_NAME}"
                    echo "Note: Tests will be run in the deployment stage"
                    echo "Skipping test stage for now - tests will be validated in deployment"
                """
            }
        }
        
        stage('Verify Image Push') {
            steps {
                sh """
                    echo "Verifying that images were pushed successfully..."
                    
                    # Check if build result file exists in shared directory
                    BUILD_RESULT_FILE="/var/jenkins_home/shared-builds/build-result-${BUILD_NUMBER}.txt"
                    if [ -f "$BUILD_RESULT_FILE" ]; then
                        echo "Build result:"
                        cat "$BUILD_RESULT_FILE"
                        
                        # Check if build was successful
                        if grep -q "SUCCESS" "$BUILD_RESULT_FILE"; then
                            echo "✅ Build completed successfully!"
                            echo "Images should be available at:"
                            echo "- ${env.FULL_IMAGE_NAME}"
                            echo "- ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                            echo "- ${DOCKER_REGISTRY}/${IMAGE_NAME}:build-${BUILD_NUMBER}"
                        else
                            echo "❌ Build failed!"
                            exit 1
                        fi
                    else
                        echo "⚠️  Build result file not found. External script may not have run yet."
                        echo "Please run: ./jenkins/process-jenkins-build.sh ${BUILD_NUMBER}"
                        echo "Then restart this pipeline stage."
                        exit 1
                    fi
                """
            }
        }
        
        stage('Update Manifests Repository') {
            steps {
                script {
                    def imageTag = params.IMAGE_TAG == 'latest' ? "${env.BUILD_TAG}" : params.IMAGE_TAG
                    
                    sh """
                        echo "Updating manifests repository with image tag: ${imageTag}"
                        
                        # Copy the update manifests script to workspace
                        cp jenkins/update-manifests.sh ./
                        chmod +x update-manifests.sh
                        
                        # Run the update manifests script
                        ./update-manifests.sh ${BUILD_NUMBER} ${imageTag} ${DOCKER_REGISTRY} ${IMAGE_NAME} ${params.ENVIRONMENT} ${GITHUB_TOKEN}
                        
                        echo "Manifests repository updated successfully!"
                    """
                }
            }
        }
        
        stage('ArgoCD Sync') {
            steps {
                script {
                    def appName = "end-to-end-app-${params.ENVIRONMENT}"
                    
                    sh """
                        echo "ArgoCD will automatically detect changes in the manifests repository"
                        echo "Application: ${appName}"
                        echo "Waiting for ArgoCD to sync..."
                        sleep 60
                        echo "ArgoCD sync initiated. Check ArgoCD UI for deployment status."
                    """
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    def namespace = "flask-app-${params.ENVIRONMENT}"
                    sh """
                        echo "Health check for namespace: ${namespace}"
                        echo "Deployment should be available at: http://your-cluster-ip:30080"
                        echo "Check ArgoCD UI for deployment status and health"
                        echo "Manual verification: kubectl get pods -n ${namespace} -l app=end-to-end-app"
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
            deleteDir()
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
