pipeline {
    agent any
    
    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Récupération du code student-management"
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean compile'
            }
        }
        
        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                    echo "JAR créé: student-management-0.0.1-SNAPSHOT.jar"
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}