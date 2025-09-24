pipeline {
    agent any
    
    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }
    
    environment {
        APP_NAME = 'student-management'
        VERSION = '0.0.1-SNAPSHOT'
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
                echo "📦 Projet: ${env.APP_NAME}"
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
                    echo "🧪 Exécution des tests..."
                    // Utilisation directe des valeurs (pas de variables pour le mot de passe vide)
                    sh 'mvn test -Dspring.datasource.url=jdbc:mysql://localhost:3306/studentdb -Dspring.datasource.username=root -Dspring.datasource.password= -Dserver.port=8089 -Dserver.servlet.context-path=/student'
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
            echo "🏁 Pipeline terminé - ${env.APP_NAME}"
            cleanWs()
        }
    }
}