pipeline {
    // Agent we will use any Agent Node in the Jenkins to run this pipeline
    agent any


    tools {
        // Mention the Tool configured in the Jenkins Server like Java, Maven, Git 
        maven 'Maven_Tool'
        jdk 'Java_Tool'
    }

    // Set Environment Variable for the Nexus to interact to download the dependencies and upload artifacts in the Nexus
    environment {

        NEXUS_USER = 'admin'
        NEXUS_PASS = 'admin'
        RELEASE_REPO = 'vprofile-release'
        CENTRAL_REPO = 'vprofile-maven-central'
        SNAP_REPO = 'vprofile-snapshot'
        NEXUS_GRP_REPO = 'vprofile-maven-group'
        NEXUSIP = '172.31.32.231'
        NEXUSPORT = '8081'
        NEXUS_LOGIN = 'NEXUS_CREDENTIALS'
        SONAR_SCANNER = 'sonarscanner'
        SONAR_SERVER_LOGIN = 'sonarserver'

    }

    stages {
        stage ('Build Applications') {
            steps {
                sh 'mvn -s settings.xml -DskipTests install' // Run Install and use setting.xml file and skip unit test
            }
            post {
                success {
                    echo 'Now Archiving'
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }

        // Test Application
        stage ('Test Application') {
            step
                sh 'mvn test'
            }
        }

        // Check Style Application for Vulnerability scan
        stage ('CheckStyle for the Application') {
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
        }

        // Upload Report to the Sonar Server to check the Vulnerability. Refer Documentation for code
        stage ('Sonar Qube Analysis') {
                environment {
                    scannerhome = tool "${SONAR_SCANNER}" // Mention the name used while configuring sonarscanner in the jenkins tools 
                }
            steps {
                withSonarQubeEnv("${SONAR_SERVER_LOGIN}") {
                    sh '''${scannerhome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                   -Dsonar.projectName=vprofile-repo \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                } 
            }
        }

    }
}