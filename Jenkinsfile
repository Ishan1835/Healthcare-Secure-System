pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                echo 'Downloading source code'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                bat 'docker build -t healthcare-app:latest .'
            }
        }

        stage('Container Scan') {
            steps {
                bat 'trivy image healthcare-app:latest'
            }
        }

        stage('Deploy') {
            steps {
                bat 'minikube image load healthcare-app:latest'
                bat 'kubectl apply -f k8s/deployment.yaml'
            }
        }

        stage('Verify') {
            steps {
                bat 'kubectl get pods'
            }
        }
    }
}
