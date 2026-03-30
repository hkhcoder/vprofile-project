pipeline {
    
	agent any
	
	tools {
        maven "maven3.9"
    }
	
    environment {
        SNAP_REPO = 'vprofile-snapshot'
    
        RELEASE_REPO = 'vprofile-release'
        CENTRAL_REPO = 'vpro-maven-central'
        NEXUSIP = '172.31.27.140'
        NEXUSPORT = '8081'
        NEXUS_GRP_REPO = 'vpro-maven-group'

        NEXUS_CREDS = credentials('nexuslogin') 
    }
	
    stages{
        
        stage('BUILD'){
            steps {
                sh 'mvn clean install -DskipTests'
            }
            post {
                success {
                    echo 'Now Archiving...'
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }

	stage('UNIT TEST'){
            steps {
                sh 'mvn test'
            }
        }

	stage('INTEGRATION TEST'){
            steps {
                sh 'mvn verify -DskipUnitTests'
            }
        }
		
        stage ('CODE ANALYSIS WITH CHECKSTYLE'){
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
            post {
                success {
                    echo 'Generated Analysis Result'
                }
            }
        }

        stage('CODE ANALYSIS with SONARQUBE') {
          
		  environment {
                scannerHome = tool 'sonarscanner4'
          }

          steps {
            withSonarQubeEnv('sonar-pro') {
                   sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                   -Dsonar.projectName=vprofile \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
            }

            timeout(time: 10, unit: 'MINUTES') {
               waitForQualityGate abortPipeline: false
            }
          }
        }
        

        stage("Publish to Nexus Repository Manager") {
    steps {
        script {
            def pom = readMavenPom file: "pom.xml"

            def filesByGlob = findFiles(glob: "target/*.${pom.packaging}")
            def artifactPath = filesByGlob[0].path

            nexusArtifactUploader(
                nexusVersion: 'nexus3',
                protocol: 'http',
                nexusUrl: '172.31.27.140:8081',
                groupId: 'QA',
                version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                repository: 'vprofile-release',
                credentialsId: 'nexuslogin',
                artifacts: [
                    [artifactId: pom.artifactId,
                     classifier: '',
                     file: artifactPath,
                     type: pom.packaging],
                    [artifactId: pom.artifactId,
                     classifier: '',
                     file: "pom.xml",
                     type: "pom"]
                ]
            )
        }
    }
}
       stage('Ansible Deploy to staging'){
            steps {
               ansiblePlaybook([
    inventory   : 'ansible/stage.inventory',
    playbook    : 'ansible/site.yml',
    installation: 'ansible',
    colorized   : true,
    credentialsId: 'applogin',
    disableHostKeyChecking: true,
    extraVars   : [
        USER: "${NEXUS_CREDS_USR}",
        PASS: "${NEXUS_CREDS_PSW}",
        nexusip: "172.31.27.140",
        reponame: "vprofile-release",
        groupid: "QA",
        time: "${env.BUILD_TIMESTAMP}",
        build: "${env.BUILD_ID}",
        artifactid: "vproapp",
        vprofile_version: "vproapp-${env.BUILD_ID}-${env.BUILD_TIMESTAMP}.war"
                ]
             ])
            }
        }

    }

    }



