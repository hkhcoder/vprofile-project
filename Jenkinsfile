pipeline {
    agent any

    tools {
        maven "MAVEN3"          // Ensure "MAVEN3" is configured in Jenkins Global Tool Configuration
        jdk "OracleJDK8"        // Ensure "OracleJDK8" is configured in Jenkins Global Tool Configuration
    }

    environment {
        SNAP_REPO = 'vprofile-snapshot'       // Corrected typo: "SANP_REPO" -> "SNAP_REPO"
        NEXUS_USER = 'admin' 
        NEXUS_PASS = 'admin123'
        RELEASE_REPO = 'vprofile-release'     // Corrected typo: "RELESASE_REPO" -> "RELEASE_REPO"
        CENTRAL_REPO = 'vpro-maven-central'
        NEXUSIP = '172.31.22.167' 
        NEXUSPORT = '8081'
        NEXUS_GRP_REPO = 'vpro-maven-group'
        NEXUS_LOGIN = 'nexuslogin'
        SONARSERVER = 'sonarserver'
        SONARSCANNER = 'sonarscanner'
    }

    stages {
        stage('Build') {
            steps {
                script {
                    // Displaying environment variables for debugging
                    sh 'echo Building with Nexus IP: $NEXUS_IP and Port: $NEXUS_PORT'
                }
                sh 'mvn -U -s settings.xml -DskipTests install'
            }
        }
        stage('Test'){
            steps{
                sh 'mvn -s settings.xml test'
            }
        }
        stage ('Checkstyle Analasis'){
            steps {
                sh 'mvn -s settings.xml checkstyle:checkstyle'
            }
        }
        stage('Sonar Analysis') {
            environment {
                scannerHome = tool "${SONARSCANNER}"
            }
            steps {
               withSonarQubeEnv("${SONARSERVER}") {
                   sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                   -Dsonar.projectName=vprofile \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
              }
            }
        }

        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage("UploadArtifact"){
            steps{
                nexusArtifactUploader(
                  nexusVersion: 'nexus3',
                  protocol: 'http',
                  nexusUrl: "${NEXUSIP}:${NEXUSPORT}",
                  groupId: 'QA',
                  version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                  repository: "${RELEASE_REPO}",
                  credentialsId: "${NEXUS_LOGIN}",
                  artifacts: [
                    [artifactId: 'vproapp',
                     classifier: '',
                     file: 'target/vprofile-v2.war',
                     type: 'war']
                  ]
                )
            }
        }

    }
}
