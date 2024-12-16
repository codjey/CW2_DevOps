pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "acaldw301/cw2-server:latest"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}", '.')
                }
            }
        }
        stage('Test Docker Image') {
            steps {
                script {
                    def app = docker.image("${DOCKER_IMAGE}").run('-d')
                    sh "docker exec ${app.id} curl localhost:8080"
                    app.stop()
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-credentials') {
                        docker.image("${DOCKER_IMAGE}").push()
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sshagent(['production-server-ssh']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no ubuntu@50.19.2.165 "
                    
                    # Delete existing service and deployment
                    kubectl delete service cw2-deployment --ignore-not-found &&
                    kubectl delete deployment cw2-deployment --ignore-not-found &&
                    
                    # Create new deployment
                    kubectl create deployment cw2-deployment --image=acaldw301/cw2-server:latest &&
                    kubectl scale deployment cw2-deployment --replicas=3 &&

                    # Expose the service
                    kubectl expose deployment cw2-deployment --type=NodePort --port=8080
                    "
                    '''
                }
            }
        }
    }
}
