pipeline {
    agent any
    
    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }
    
    environment {
        // Ces valeurs seront écrasées par la lecture du pom.xml
        APP_NAME = ''
        VERSION = ''
        GROUP_ID = ''
    }
    
    stages {
        stage('Initialisation Projet') {
            steps {
                script {
                    // Lecture des informations depuis pom.xml
                    def pom = readMavenPom file: 'pom.xml'
                    env.APP_NAME = pom.artifactId
                    env.VERSION = pom.version
                    env.GROUP_ID = pom.groupId
                    env.PROJECT_NAME = pom.name
                    
                    echo "=== INFORMATIONS DU PROJET STUDENT MANAGEMENT ==="
                    echo "Application: ${env.APP_NAME}"
                    echo "Version: ${env.VERSION}"
                    echo "Groupe: ${env.GROUP_ID}"
                    echo "Nom: ${env.PROJECT_NAME}"
                    echo "Java Version: ${pom.properties['java.version']}"
                }
            }
        }
        
        stage('Checkout Code') {
            steps {
                checkout scm
                script {
                    echo "Code source récupéré pour ${env.APP_NAME}"
                }
            }
        }
        
        stage('Build et Compilation') {
            steps {
                script {
                    echo "Construction de ${env.APP_NAME} version ${env.VERSION}"
                    sh 'mvn clean compile'
                }
            }
        }
        
        stage('Tests Unitaires') {
            steps {
                script {
                    echo "Exécution des tests unitaires..."
                    sh 'mvn test'
                }
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                    jacoco(
                        execPattern: 'target/jacoco.exec',
                        classPattern: 'target/classes',
                        sourcePattern: 'src/main/java',
                        exclusionPattern: 'src/test*'
                    )
                }
            }
        }
        
        stage('Packaging') {
            steps {
                script {
                    echo "Création du package JAR..."
                    sh 'mvn package -DskipTests'
                    
                    // Vérification du fichier JAR généré
                    def jarFile = sh(
                        script: "ls target/*.jar | head -1",
                        returnStdout: true
                    ).trim()
                    
                    env.JAR_FILE = jarFile
                    echo "Fichier JAR généré: ${jarFile}"
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: "target/${env.APP_NAME}-${env.VERSION}.jar", fingerprint: true
                    echo "✅ Package créé avec succès: ${env.APP_NAME}-${env.VERSION}.jar"
                }
            }
        }
        
        stage('Analyse Code') {
            steps {
                script {
                    echo "Analyse de la qualité du code..."
                    sh 'mvn spotbugs:check checkstyle:check'
                }
            }
        }
        
        stage('Génération Documentation') {
            steps {
                script {
                    echo "Génération de la documentation OpenAPI..."
                    sh 'mvn spring-boot:run &'
                    sleep time: 30, unit: 'SECONDS'
                    sh 'curl http://localhost:8080/v3/api-docs -o target/openapi.json'
                    sh 'pkill -f spring-boot'
                    
                    archiveArtifacts artifacts: 'target/openapi.json', fingerprint: true
                }
            }
        }
        
        stage('Déploiement Dev') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    echo "🚀 Déploiement en développement de ${env.APP_NAME}"
                    // Ajouter ici vos commandes de déploiement spécifiques
                    // Exemple: déploiement Docker, déploiement sur serveur, etc.
                    
                    // Exemple pour Docker:
                    // sh "docker build -t ${env.APP_NAME}:${env.VERSION} ."
                    // sh "docker run -d -p 8080:8080 ${env.APP_NAME}:${env.VERSION}"
                }
            }
        }
    }
    
    post {
        always {
            echo "=== RAPPORT DU PIPELINE ==="
            echo "Projet: ${env.APP_NAME}"
            echo "Version: ${env.VERSION}"
            echo "Statut: ${currentBuild.currentResult}"
            echo "Durée: ${currentBuild.durationString}"
            echo "URL du build: ${env.BUILD_URL}"
            
            cleanWs() // Nettoyage de l'espace de travail
        }
        success {
            emailext (
                subject: "✅ SUCCÈS: Student Management Build ${env.BUILD_NUMBER}",
                body: """
                Le pipeline de ${env.APP_NAME} s'est terminé avec succès!
                
                Détails:
                - Application: ${env.APP_NAME}
                - Version: ${env.VERSION}
                - Build: ${env.BUILD_NUMBER}
                - Durée: ${currentBuild.durationString}
                - URL: ${env.BUILD_URL}
                
                Fichier JAR généré: ${env.APP_NAME}-${env.VERSION}.jar
                """,
                to: "devops@example.com",
                attachLog: true
            )
            
            // Notification Slack optionnelle
            // slackSend channel: '#devops', message: "✅ Build réussi: ${env.APP_NAME} v${env.VERSION}"
        }
        failure {
            emailext (
                subject: "❌ ÉCHEC: Student Management Build ${env.BUILD_NUMBER}",
                body: """
                Le pipeline de ${env.APP_NAME} a échoué!
                
                Détails:
                - Application: ${env.APP_NAME}
                - Version: ${env.VERSION}
                - Build: ${env.BUILD_NUMBER}
                - URL: ${env.BUILD_URL}
                
                Consulter les logs pour plus de détails.
                """,
                to: "devops@example.com",
                attachLog: true
            )
        }
        unstable {
            echo "⚠️ Le build est instable - vérifier les tests"
        }
    }
}