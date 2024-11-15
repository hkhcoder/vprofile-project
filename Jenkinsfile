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


       stage('Unit Test') {
            steps{
            #    sh 'mvn test -DskipTests'
            }
        }


	    stage('Build'){
	        steps{
	           sh 'mvn install'
	        }

	        post {
	           success {
	              echo 'Now Archiving...'
	              archiveArtifacts artifacts: '**/target/*.war'
	           }
	        }
	    }

	    
	}
}
