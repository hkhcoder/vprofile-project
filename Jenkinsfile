pipeline {
	agent any
	tools {
	    maven "Maven"
	    jdk "JDK17"
	}

	stages {
	    stage('Fetch code') {
            steps {
               git branch: 'atom', url: 'https://github.com/cece69/vprofile-project2.git'
            }

	    }


       stage('UNIT TEST') {
            steps{
                sh 'mvn test'
            }
        }


	    stage('Build'){
	        steps{
	           sh 'mvn install -DskipTests'
	        }

	        post {
	           success {
	              echo 'Now Archiving it...'
	              archiveArtifacts artifacts: '**/target/*.war'
	           }
	        }
	    }

	    
	}
}
