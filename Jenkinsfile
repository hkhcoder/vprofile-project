pipeline {
    agent any
    tools {
        maven "Maven3.9"
        jdk "JDK17"
    }
    
    environment {
        SNAP_REPO = 'vprofile-snapshot'
		NEXUS_USER = 'admin'
		NEXUS_PASS = 'Myworld@1997@'
		RELEASE_REPO = 'vprofile-release'
		CENTRAL_REPO = 'vpro-maven-central'
		NEXUSIP = '172.31.6.37'
		NEXUSPORT = '8081'
		NEXUS_GRP_REPO = 'vpro-maven-group'
        NEXUS_LOGIN = 'Nexuslogin'
    }

    stages {
        stage('Build'){
            steps {
                sh 'mvn -s settings.xml -DskipTests install'
            }
            post {
                success {
                       
                       echo "Now Archiving."
                       archiveArtifacts artifacts: '**/*.war'
                }
                 
            }
        }
        stage('Test'){
            steps {

                 sh 'mvn -s settings.xml test'
                 echo "Testing"

            }
s
        }
        stage('Checkstyle Analysis'){

            steps {

                sh 'mvn -s settings.xml checkstyle:checkstyle'
                echo "done1"

            }
        }

    }
       

}