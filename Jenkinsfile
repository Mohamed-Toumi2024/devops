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
        SONARQUBE_CONTAINER = 'sonarqube'
        SONARQUBE_PORT = '9000'
    }

    stages {
        // ────────────────────────────────
        stage('Checkout Code') {
            steps {
                echo "📦 Clonage du code source..."
                checkout scm
            }
        }

        // ────────────────────────────────
        stage('Start SonarQube') {
            steps {
                script {
                    echo "🐳 Démarrage de SonarQube (localhost:9000)..."
                    sh '''
                        docker rm -f sonarqube || true
                        docker run -d --name sonarqube \
                            -p 9000:9000 \
                            sonarqube:lts-community
                        echo "⏳ Attente de 30s pour que SonarQube démarre..."
                        sleep 30
                    '''
                }
            }
        }

        // ────────────────────────────────
        stage('Build & Test') {
            steps {
                echo "🧹 Compilation et exécution des tests avec JaCoCo..."
                sh '''
                    mvn clean compile test jacoco:report
                '''
            }
        }

        // ────────────────────────────────
        stage('SonarQube Analysis') {
            steps {
                echo "🔍 Analyse du code avec SonarQube..."
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_AUTH_TOKEN')]) {
                    sh """
                        mvn sonar:sonar \
                            -Dsonar.projectKey=${APP_NAME} \
                            -Dsonar.host.url=http://localhost:${SONARQUBE_PORT} \
                            -Dsonar.login=${SONAR_AUTH_TOKEN} \
                            -Dsonar.java.binaries=target/classes \
                            -Dsonar.junit.reportPaths=target/surefire-reports \
                            -Dsonar.jacoco.reportPaths=target/jacoco.exec
                    """
                }
            }
        }

        // ────────────────────────────────
        stage('Build & Push Docker Image') {
            steps {
                echo "🐳 Construction et push de l'image Docker..."
                sh "docker build -t ${DOCKER_IMAGE} ."
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                        docker push ${DOCKER_IMAGE}
                    """
                }
            }
        }

        // ────────────────────────────────
        stage('Deploy to Kubernetes') {
            steps {
                echo "🚀 Déploiement sur Minikube (Kubernetes)..."
                sh '''
                    kubectl config use-context minikube
                    echo "📦 Application des fichiers YAML..."
                    kubectl apply -f secret.yaml
                    kubectl apply -f mysql-deployment.yaml
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml

                    echo "⏳ Attente du déploiement..."
                    kubectl rollout status deployment/student-management
                '''
            }
        }
    }

    // ────────────────────────────────
    post {
        always {
            echo "🏁 Nettoyage..."
            sh 'docker rm -f sonarqube || true'
            cleanWs()
        }
        success {
            echo "✅ Pipeline terminé avec succès et app déployée sur Kubernetes."
        }
        failure {
            echo "❌ Le pipeline a échoué. Vérifie les logs Jenkins."
        }
    }
}
