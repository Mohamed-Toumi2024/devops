pipeline {
    agent any
    
    tools {
        maven 'M2_HOME'  // Utilise 'M3' au lieu de 'M2_HOME'
        jdk 'JAVA_HOME' // Utilise le nom JDK configuré dans Jenkins
    }
    
    environment {
        APP_NAME = 'student-management'
        VERSION = '0.0.1-SNAPSHOT'
        DB_URL = 'jdbc:mysql://localhost:3306/studentdb'
        DB_USERNAME = 'root'
        DB_PASSWORD = ''
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
                echo "📦 Projet: ${APP_NAME}"
            }
        }
        
        stage('Build et Compilation') {
            steps {
                script {
                    echo "🔨 Compilation de l'application..."
                    sh 'mvn clean compile'
                }
            }
        }
        
        stage('Tests Unitaires') {
            steps {
                script {
                    echo "🧪 Exécution des tests avec MySQL..."
                    sh """
                        mvn test \
                        -Dspring.datasource.url=${DB_URL} \
                        -Dspring.datasource.username=${DB_USERNAME} \
                        -Dspring.datasource.password=${DB_PASSWORD} \
                        -Dserver.port=8089 \
                        -Dserver.servlet.context-path=/student
                    """
                }
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Packaging') {
            steps {
                script {
                    echo "📦 Création du package JAR..."
                    sh 'mvn package -DskipTests'
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                    echo "✅ Package créé avec succès!"
                }
            }
        }
    }
    
    post {
        always {
            echo "🏁 Pipeline terminé - ${APP_NAME}"
            cleanWs()
        }
        success {
            echo "✅ SUCCÈS: Build ${APP_NAME} réussi!"
        }
        failure {
            echo "❌ ÉCHEC: Build ${APP_NAME} a échoué"
        }
    }
}