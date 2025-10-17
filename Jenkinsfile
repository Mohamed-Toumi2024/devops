pipeline {
    agent any

    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }

    environment {
        APP_NAME = 'student-management'
        VERSION = '0.0.1-SNAPSHOT'
        DOCKER_IMAGE = "toumimohameddhia2025/${APP_NAME}:${VERSION}"
        K8S_NAMESPACE = 'devops'
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
                echo "📦 Projet: ${env.APP_NAME}"
            }
        }

        stage('Deploy MySQL in Kubernetes') {
            steps {
                echo "🐳 Déploiement de MySQL dans Kubernetes..."
                sh "kubectl apply -f k8s/mysql-deployment.yaml -n ${K8S_NAMESPACE}"
                echo "⏳ Attente que MySQL soit prêt..."
                sh "kubectl wait --for=condition=ready pod -l app=mysql -n ${K8S_NAMESPACE} --timeout=60s"
            }
        }

        stage('Build & Test') {
            steps {
                echo "🧹 Compilation et exécution des tests Maven..."
                sh "mvn clean test -Dspring.profiles.active=test"
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Construction de l'image Docker ${DOCKER_IMAGE}..."
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "📤 Push de l'image vers Docker Hub..."
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Deploy Application in Kubernetes') {
            steps {
                echo "🚀 Déploiement de l'application dans Kubernetes..."
                sh "kubectl apply -f k8s/deployment.yaml -n ${K8S_NAMESPACE}"
                sh "kubectl apply -f k8s/service.yaml -n ${K8S_NAMESPACE}"
            }
        }
    }

    post {
        always {
            echo "🏁 Pipeline terminé pour ${env.APP_NAME}"
        }
        failure {
            echo "❌ Le pipeline a échoué !"
        }
        success {
            echo "✅ Déploiement et tests réussis avec Kubernetes !"
        }
    }
}
