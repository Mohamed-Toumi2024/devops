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

        # --- Kubernetes pods/services ---
        K8S_NAMESPACE = 'student-management'
        SONAR_SERVICE = 'sonarqube'
        SONAR_PORT = '9000'
        SONAR_URL = "http://${SONAR_SERVICE}.${K8S_NAMESPACE}.svc.cluster.local:${SONAR_PORT}"

        MYSQL_SERVICE = 'mysql'
        POSTGRES_SERVICE = 'postgresql'
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
                sh 'mvn clean compile -DskipTests'
            }
        }

        stage('Check K8s Pods') {
            steps {
                echo "🔎 Vérification des pods SonarQube, MySQL et PostgreSQL sur Kubernetes..."
                sh '''
                    kubectl --kubeconfig=/home/toumi/.kube/config get pods -n ${K8S_NAMESPACE}

                    echo "⏳ Attente que SonarQube soit prêt..."
                    kubectl wait --for=condition=ready pod -l app=${SONAR_SERVICE} -n ${K8S_NAMESPACE} --timeout=180s

                    echo "⏳ Attente que MySQL soit prêt..."
                    kubectl wait --for=condition=ready pod -l app=${MYSQL_SERVICE} -n ${K8S_NAMESPACE} --timeout=180s

                    echo "⏳ Attente que PostgreSQL soit prêt..."
                    kubectl wait --for=condition=ready pod -l app=${POSTGRES_SERVICE} -n ${K8S_NAMESPACE} --timeout=180s
                '''
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
                echo "🔍 Analyse SonarQube sur le pod distant..."
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_AUTH_TOKEN')]) {
                    sh """
                        mvn sonar:sonar \
                            -Dsonar.projectKey=${APP_NAME} \
                            -Dsonar.host.url=${SONAR_URL} \
                            -Dsonar.login=${SONAR_AUTH_TOKEN}
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Construction de l'image Docker..."
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE}
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "📋 Nettoyage terminé. Fin du pipeline."
        }
    }
}
