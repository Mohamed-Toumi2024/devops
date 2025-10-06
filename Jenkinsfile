pipeline {
    agent any

    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }

    environment {
        APP_NAME = 'student-management'
        VERSION = '0.0.1-SNAPSHOT'
        DOCKER_IMAGE = "toumimohameddhia2025/${APP_NAME}:${VERSION}" // ton Docker Hub user
        SONARQUBE = 'SonarQube' // Nom du serveur SonarQube configuré dans Jenkins
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
                echo "🧹 Nettoyage et compilation du projet..."
                sh 'mvn clean compile'
            }
        }

        stage('Start DB for Tests') {
            steps {
                echo "🐳 Démarrage de MySQL via Docker Compose..."
                sh "docker-compose up -d db"
                echo "⏳ Attente 15s pour que MySQL soit prêt"
                sh "sleep 15"
            }
        }

        stage('Run Tests & Jacoco') {
            steps {
                echo "🧪 Exécution des tests unitaires et génération du rapport Jacoco..."
                sh 'mvn test jacoco:report'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo "🔍 Analyse SonarQube..."
                withSonarQubeEnv("${SONARQUBE}") {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_AUTH_TOKEN')]) {
                        sh """
                            mvn sonar:sonar \
                                -Dsonar.projectKey=${APP_NAME} \
                                -Dsonar.host.url=${env.SONAR_HOST_URL} \
                                -Dsonar.login=${SONAR_AUTH_TOKEN} \
                                -Dsonar.java.binaries=target/classes \
                                -Dsonar.junit.reportPaths=target/surefire-reports \
                                -Dsonar.jacoco.reportPaths=target/jacoco.exec
                        """
                    }
                }
            }
        }

        stage('Package') {
            steps {
                echo "📦 Création du JAR..."
                sh 'mvn package'
            }
        }

        stage('Archive') {
            steps {
                echo "📦 Archivage du JAR"
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
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

        stage('Deploy with Docker Compose') {
            steps {
                echo "🚀 Déploiement avec docker-compose..."
                sh "docker-compose down -v || true"
                sh "docker-compose up -d --build"
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
