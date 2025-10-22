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
        KUBECONFIG = '/var/lib/jenkins/.kube/config' // kubeconfig pour Jenkins
        MYSQL_ROOT_PASSWORD = 'root'
        MYSQL_SERVICE_NAME = 'mysql-service'
        MYSQL_DATABASE = 'studentdb'
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
                sh """
                    export KUBECONFIG=${KUBECONFIG}
                    kubectl apply -f k8s/mysql-deployment.yaml -n ${K8S_NAMESPACE} --validate=false
                    echo "⏳ Attente que MySQL soit prêt..."
                    kubectl wait --for=condition=ready pod -l app=mysql -n ${K8S_NAMESPACE} --timeout=180s
                """
            }
        }

        stage('Check MySQL') {
            steps {
                echo "🔍 Vérification que MySQL est accessible..."
                sh """
                    export KUBECONFIG=${KUBECONFIG}
                    MYSQL_POD=\$(kubectl get pod -l app=mysql -n ${K8S_NAMESPACE} -o jsonpath='{.items[0].metadata.name}')
                    kubectl exec -n ${K8S_NAMESPACE} \$MYSQL_POD -- mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e 'SHOW DATABASES;'
                """
            }
        }

        stage('Build & Test Maven') {
            steps {
                echo "🧹 Compilation et tests Maven..."
                sh """
                    export KUBECONFIG=${KUBECONFIG}
                    mvn clean test -Dspring.profiles.active=test \
                        -Dspring.datasource.url=jdbc:mysql://${MYSQL_SERVICE_NAME}:3306/${MYSQL_DATABASE} \
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
                    kubectl logs -n ${K8S_NAMESPACE} \$APP_POD
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
            echo "✅ Déploiement et tests réussis avec Kubernetes !"
        }
    }
}
