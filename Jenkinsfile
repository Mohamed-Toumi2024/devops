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
        
        stage('Build et Package') {
            steps {
                script {
                    echo "🔨 Construction du package..."
                    // Skip tests car MySQL n'est pas disponible dans Jenkins
                    sh 'mvn clean package -DskipTests'
                }
            }
        }
        
        stage('Archive Artifact') {
            steps {
                script {
                    echo "📦 Archivage du JAR..."
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                    
                    // Afficher les informations du fichier généré
                    def files = findFiles(glob: 'target/*.jar')
                    if (files.length > 0) {
                        echo "✅ Fichier généré: ${files[0].name}"
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo "🏁 Pipeline terminé pour ${env.APP_NAME}"
            cleanWs()
        }
        success {
            echo "✅ SUCCÈS: Build complété avec succès!"
        }
    }
}