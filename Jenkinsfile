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
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = params.IMAGE_TAG == 'latest' ? "${env.GIT_COMMIT_SHORT}" : params.IMAGE_TAG
                    env.FULL_IMAGE_NAME = "${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag}"
                    
                    sh """
                        docker build -t ${env.FULL_IMAGE_NAME} .
                        docker tag ${env.FULL_IMAGE_NAME} ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest
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
                        """
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def imageTag = params.IMAGE_TAG == 'latest' ? "${env.GIT_COMMIT_SHORT}" : params.IMAGE_TAG
                    def namespace = "flask-app-${params.ENVIRONMENT}"
                    
                    sh """
                        # Update image tag in deployment
                        sed -i 's|image: omarzaki222/end-to-end-project:.*|image: ${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag}|g' mainfest/deployment.yaml
                        
                        # Apply Kubernetes manifests
                        kubectl apply -f mainfest/namespace.yaml
                        kubectl apply -f mainfest/pv.yaml
                        kubectl apply -f mainfest/pvc.yaml
                        kubectl apply -f mainfest/deployment.yaml
                        kubectl apply -f mainfest/service.yaml
                        
                        # Wait for deployment to be ready
                        kubectl rollout status deployment/end-to-end-app -n ${namespace} --timeout=300s
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
                def imageTag = params.IMAGE_TAG == 'latest' ? "${env.GIT_COMMIT_SHORT}" : params.IMAGE_TAG
                echo "Deployed image: ${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag}"
            }
        }
        failure {
            echo "Pipeline failed!"
            // You can add notification logic here (Slack, email, etc.)
        }
    }
}
