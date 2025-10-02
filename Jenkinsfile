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
        
        stage('Clean') {
            steps {
                script {
                    echo "🧹 Nettoyage du projet..."
                    sh 'mvn clean'
                    echo "✅ Nettoyage terminé"
                }
            }
        }
        
        stage('Compile') {
            steps {
                script {
                    echo "🔨 Compilation du code..."
                    sh 'mvn compile'
                    echo "✅ Compilation réussie"
                }
            }
        }
        
        stage('Package') {
            steps {
                script {
                    echo "📦 Création du JAR..."
                    sh 'mvn package -DskipTests'
                    echo "✅ Package créé"
                }
            }
        }
        
        stage('Archive') {
            steps {
                script {
                    echo "📦 Archivage d'artefact"
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                    echo "✅ Artifact archivé"
                }
            }
        }
    }
    
    post {
        always {
            echo "🏁 Pipeline terminé pour ${env.APP_NAME}"
            cleanWs()
        }
    }
}