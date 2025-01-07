pipeline {
    agent any

    tools {
        maven "MAVEN3"          // Ensure "MAVEN3" is configured in Jenkins Global Tool Configuration
        jdk "OracleJDK8"        // Ensure "OracleJDK8" is configured in Jenkins Global Tool Configuration
    }

    environment {
        SNAP_REPO = 'vprofile-snapshot'       // Corrected typo: "SANP_REPO" -> "SNAP_REPO"
        NEXUS_USER = 'admin' 
        NEXUS_PASS = 'Admin@431'
        RELEASE_REPO = 'vprofile-release'     // Corrected typo: "RELESASE_REPO" -> "RELEASE_REPO"
        CENTRAL_REPO = 'vpro-maven-central'
        NEXUSIP = '172.31.25.180' 
        NEXUSPORT = '8081'
        NEXUS_GRP_REPO = 'vpro-maven-group'
        NEXUS_LOGIN = 'nexuslogin'
    }

    stages {
        stage('Build') {
            steps {
                script {
                    // Displaying environment variables for debugging
                    sh 'echo Building with Nexus IP: $NEXUS_IP and Port: $NEXUS_PORT'
                }
                sh 'mvn -s settings.xml -DskipTests install'
            }
            post {
                success {
                    echo "Now Archiving"
                    archiveArtifacts artifacts: '**/*.war'
                }
                
            }
        }

        stage('Test'){
            steps{
                sh 'mvn test'
            }
        }
        stage ('Checkstyle Analasis'){
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
        }
    }
}
