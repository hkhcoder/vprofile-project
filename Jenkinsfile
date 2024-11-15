pipeline {
	agent any
	tools {
	    maven "Maven"
	    jdk "JDK17"
	}

	stages {
	    stage('Fetch Code') {
            steps {
               git branch: 'pipeline', url: 'https://github.com/cece69/vprofile-project2.git/'
               }
	    }

	    stage('Build') {
	        steps {
	           echo "starting install via sh mvn install"
	        }
	    }
		
       stage('Unit Test') {
            steps {
            	echo "starting test via sh mvn test"
            }
        }
		
	stage('Checkstyle Analysis') {
	     steps {
		sh 'mvn checkstyle:checkstyle'
	     }
	}

	stage('Sonar Code Analysis') {
	    environment {
	        scannerHome = tool 'sonarqube_scanner'
	    }
	    steps {
	        withSonarQubeEnv('sonarqube_server') {
		   sh 'mvn clean package sonar:sonar'
		}
	    }
	}
   }
}
