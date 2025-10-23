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
        K8S_NAMESPACE = 'student-management'
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
        MYSQL_ROOT_PASSWORD = 'root'
        MYSQL_SERVICE_NAME = 'mysql-service'
        MYSQL_DATABASE = 'studentdb'
        SONARQUBE_SERVER = 'SonarQube'
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
                echo "📦 Projet: ${env.APP_NAME}"
            }
        }

        stage('SonarQube Code Analysis') {
            steps {
                echo "🔍 Analyse du code avec SonarQube..."
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh "mvn clean verify sonar:sonar -Dsonar.projectKey=${APP_NAME}"
                }
            }
        }

        stage('Deploy MySQL in Kubernetes') {
            steps {
                echo "🐳 Déploiement de MySQL dans Kubernetes..."
                sh """
                    export KUBECONFIG=${KUBECONFIG}
                    kubectl apply -f k8s/mysql-deployment.yaml -n ${K8S_NAMESPACE} --validate=false
                    echo "⏳ Attente que MySQL soit prêt..."
                    kubectl wait --for=condition=ready pod -l app=mysql -n ${K8S_NAMESPACE} --timeout=180s
                    echo "✅ MySQL pod prêt."
                """
            }
        }

        stage('Check MySQL Availability') {
            steps {
                echo "🔍 Vérification de la connectivité MySQL..."
                sh """
                    export KUBECONFIG=${KUBECONFIG}
                    MYSQL_POD=\$(kubectl get pod -l app=mysql -n ${K8S_NAMESPACE} -o jsonpath='{.items[0].metadata.name}')
                    kubectl exec -n ${K8S_NAMESPACE} \$MYSQL_POD -- mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e 'SELECT 1;'
                    echo "✅ Connexion MySQL OK."
                """
            }
        }

        stage('Build & Test Maven') {
            steps {
                echo "🧹 Compilation et tests Maven avec MySQL..."
                sh """
                    mvn clean test -Dspring.datasource.url=jdbc:mysql://${MYSQL_SERVICE_NAME}:3306/${MYSQL_DATABASE} \
                        -Dspring.datasource.username=root \
                        -Dspring.datasource.password=${MYSQL_ROOT_PASSWORD}
                """
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
                echo "📤 Push de l'image Docker vers Docker Hub..."
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Deploy Spring Boot App in Kubernetes') {
            steps {
                echo "🚀 Déploiement de l'application Spring Boot..."
                sh """
                    export KUBECONFIG=${KUBECONFIG}
                    kubectl apply -f k8s/deployment.yaml -n ${K8S_NAMESPACE} --validate=false
                    kubectl apply -f k8s/service.yaml -n ${K8S_NAMESPACE} --validate=false
                    kubectl wait --for=condition=available deployment/${APP_NAME} -n ${K8S_NAMESPACE} --timeout=180s
                """
            }
        }

        stage('Check Application Logs') {
            steps {
                echo "📄 Vérification des logs du pod Spring Boot..."
                sh """
                    export KUBECONFIG=${KUBECONFIG}
                    APP_POD=\$(kubectl get pod -l app=${APP_NAME} -n ${K8S_NAMESPACE} -o jsonpath='{.items[0].metadata.name}')
                    kubectl logs -n ${K8S_NAMESPACE} \$APP_POD --tail=50
                """
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
            echo "✅ Déploiement complet réussi (SonarQube + DockerHub + Kubernetes) !"
        }
    }
}
