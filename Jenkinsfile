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
                    ssh -o StrictHostKeyChecking=no ubuntu@<production-server-ip> "
                    # Delete existing service and deployment
                    kubectl delete service cw2-deployment --ignore-not-found &&
                    kubectl delete deployment cw2-deployment --ignore-not-found &&
                    
                    # Create deployment and expose service
                    kubectl create deployment cw2-deployment --image=${DOCKER_IMAGE} &&
                    kubectl scale deployment cw2-deployment --replicas=3 &&
                    kubectl expose deployment cw2-deployment --type=NodePort --port=8080 &&
                    
                    # Retrieve the NodePort and store it for testing
                    export NODE_PORT=\$(kubectl get service cw2-deployment -o go-template='{{(index .spec.ports 0).nodePort}}') &&
                    
                    # Verify the application is running
                    curl http://$(minikube ip):\$NODE_PORT
                    "
                    '''
                }
            }
        }
    }
}
