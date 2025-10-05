pipeline {
    agent any

    tools {
        maven 'M2_HOME'   // nom du Maven installé sur Jenkins
        jdk 'JAVA_HOME'   // nom du JDK installé sur Jenkins
    }

    environment {
        APP_NAME = 'student-management'
        VERSION = '0.0.1-SNAPSHOT'
        DOCKER_IMAGE = "toumimohameddhia2025/${APP_NAME}:${VERSION}" // Docker Hub user
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
                sh 'mvn clean compile'
            }
        }

        stage('Start DB for Tests') {
            steps {
                echo "🐳 Démarrage MySQL pour les tests..."
                sh "docker-compose up -d db"
                sh "sleep 15"  // attendre que MySQL soit prêt
            }
        }

        stage('Run Unit Tests & Jacoco') {
            steps {
                echo "🧪 Exécution des tests unitaires et génération du rapport Jacoco..."
                sh "mvn test jacoco:report"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE}") {
                    sh """
                        mvn sonar:sonar \
                            -Dsonar.projectKey=${APP_NAME} \
                            -Dsonar.host.url=${env.SONAR_HOST_URL} \
                            -Dsonar.login=${env.SONAR_AUTH_TOKEN} \
                            -Dsonar.java.binaries=target/classes \
                            -Dsonar.junit.reportPaths=target/surefire-reports \
                            -Dsonar.jacoco.reportPaths=target/jacoco.exec
                    """
                }
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
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
