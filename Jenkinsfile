pipeline {
    agent any
    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        SSH_CREDENTIALS_ID = 'production-server-ssh'
        DOCKER_IMAGE = 'acaldw301/cw2-server'
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
                    docker.build("${DOCKER_IMAGE}:latest", '.')
                }
            }
        }
        stage('Test Docker Image') {
            steps {
                script {
                    def app = docker.image("${DOCKER_IMAGE}:latest").run('-d')
                    sh "docker exec ${app.id} curl localhost:8080"
                    app.stop()
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', DOCKER_CREDENTIALS_ID) {
                        docker.image("${DOCKER_IMAGE}:latest").push()
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sshagent([SSH_CREDENTIALS_ID]) {
                    sh '''
                    kubectl set image deployment/cw2-deployment cw2-server=${DOCKER_IMAGE}:latest --record
                    kubectl rollout status deployment/cw2-deployment
                    '''
                }
            }
        }
    }
}
