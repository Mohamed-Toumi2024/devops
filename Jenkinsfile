pipeline {
    agent any

    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }

    environment {
        APP_NAME = 'student-management'
        VERSION = '0.0.1-SNAPSHOT'
        DOCKER_IMAGE = "toumi/${APP_NAME}:${VERSION}"   // remplace par ton Docker Hub user
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
                echo "📦 Projet: ${env.APP_NAME}"
            }
        }

        stage('Clean & Compile') {
            steps {
                script {
                    echo "🧹 Nettoyage et compilation du projet..."
                    sh 'mvn clean compile'
                }
            }
        }

        stage('Package') {
            steps {
                script {
                    echo "📦 Création du JAR..."
                    sh 'mvn package -DskipTests'
                }
            }
        }

        stage('Archive') {
            steps {
                script {
                    echo "📦 Archivage du JAR"
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "🐳 Construction de l'image Docker ${DOCKER_IMAGE}..."
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "📤 Push de l'image vers Docker Hub..."
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}"
                    }
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                script {
                    echo "🚀 Déploiement avec docker-compose..."
                    // Stop containers proprement avant de relancer
                    sh "docker-compose down -v || true"
                    sh "docker-compose up -d --build"
                }
            }
        }
    }

    post {
        always {
            echo "🏁 Pipeline terminé pour ${env.APP_NAME}"
            cleanWs()
        }
        failure {
            echo "❌ Le pipeline a échoué !"
        }
        success {
            echo "✅ Déploiement réussi sur Docker !"
        }
    }
}
