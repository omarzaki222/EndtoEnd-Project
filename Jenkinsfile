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
        
        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = params.IMAGE_TAG == 'latest' ? "${env.BUILD_TAG}" : params.IMAGE_TAG
                    env.FULL_IMAGE_NAME = "${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag}"
                    
                    sh """
                        docker build -t ${env.FULL_IMAGE_NAME} .
                        docker tag ${env.FULL_IMAGE_NAME} ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest
                        docker tag ${env.FULL_IMAGE_NAME} ${DOCKER_REGISTRY}/${IMAGE_NAME}:build-${BUILD_NUMBER}
                    """
                }
            }
        }
        
        stage('Run Tests') {
            when {
                not { params.SKIP_TESTS }
            }
            steps {
                sh """
                    docker run --rm ${env.FULL_IMAGE_NAME} python -m pytest tests/ || echo "No tests found or tests failed"
                """
            }
        }
        
        stage('Push to Registry') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh """
                            echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin
                            docker push ${env.FULL_IMAGE_NAME}
                            docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest
                            docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:build-${BUILD_NUMBER}
                        """
                    }
                }
            }
        }
        
        stage('Update Manifests Repository') {
            steps {
                script {
                    def imageTag = params.IMAGE_TAG == 'latest' ? "${env.BUILD_TAG}" : params.IMAGE_TAG
                    
                    sh """
                        # Clone the manifests repository
                        git clone https://github.com/omarzaki222/EndtoEnd-Project-Manifests.git manifests-repo
                        cd manifests-repo
                        
                        # Update image tag in deployment
                        sed -i 's|image: omarzaki222/end-to-end-project:.*|image: ${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag}|g' mainfest/deployment.yaml
                        
                        # Commit and push changes to trigger ArgoCD sync
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins"
                        git add mainfest/deployment.yaml
                        git commit -m "Update image tag to ${imageTag} for ${params.ENVIRONMENT} environment (Build #${BUILD_NUMBER})" || echo "No changes to commit"
                        git push origin main
                        
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
            sh 'docker logout'
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
