pipeline {
    agent any
    tools {
        maven "MAVEN3.9.9"
        jdk "JDK21"
    }
    
    environment {
        SNAP_REPO = 'vprofile-snapshot'
		NEXUS_USER = 'admin'
		NEXUS_PASS = 'dobri1989'
		RELEASE_REPO = 'vprofile-release'
		CENTRAL_REPO = 'vpro-maven-central'
		NEXUSIP = '10.0.1.4'
		NEXUSPORT = '8081'
		NEXUS_GRP_REPO = 'vpro-maven-group'
        NEXUS_LOGIN = 'nexuslogin'
    }

    stages {
        stage('Build'){
            steps {
                sh 'mvn -s settings.xml -DskipTests install'
            }
        }
    }
}