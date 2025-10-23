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

        // Services Kubernetes exposés
        MYSQL_HOST = '192.168.49.2'       // IP Minikube ou Node
        MYSQL_PORT = '30306'
        SONAR_HOST_URL = 'http://192.168.49.2:30900'
        SONAR_TOKEN = credentials('sonar-token')

        K8S_NAMESPACE = 'student-management'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/toumimohameddhia2025/student-management.git'
            }
        }

        stage('Build & Unit Tests') {
            steps {
                sh """
                    mvn clean verify \
                    -Dspring.datasource.url=jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/studentdb \
                    -Dspring.datasource.username=root \
                    -Dspring.datasource.password=root
                """
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                        mvn sonar:sonar \
                        -Dsonar.projectKey=${APP_NAME} \
                        -Dsonar.host.url=${SONAR_HOST_URL} \
                        -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${DOCKER_IMAGE} .
                    echo "${DOCKER_HUB_PASSWORD}" | docker login -u "${DOCKER_HUB_USER}" --password-stdin
                    docker push ${DOCKER_IMAGE}
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                    kubectl apply -f k8s/mysql-deployment.yaml -n ${K8S_NAMESPACE}
                    kubectl apply -f k8s/mysql-service.yaml -n ${K8S_NAMESPACE}

                    kubectl apply -f k8s/postgresql-deployment.yaml -n ${K8S_NAMESPACE}
                    kubectl apply -f k8s/postgresql-service.yaml -n ${K8S_NAMESPACE}

                    kubectl apply -f k8s/sonarqube-deployment.yaml -n ${K8S_NAMESPACE}
                    kubectl apply -f k8s/sonarqube-service.yaml -n ${K8S_NAMESPACE}

                    kubectl apply -f k8s/student-management-deployment.yaml -n ${K8S_NAMESPACE}
                    kubectl apply -f k8s/student-management-service.yaml -n ${K8S_NAMESPACE}
                """
            }
        }

        stage('Post-Deployment Check') {
            steps {
                sh """
                    kubectl get pods -n ${K8S_NAMESPACE}
                    kubectl get svc -n ${K8S_NAMESPACE}
                """
            }
        }
    }
}
