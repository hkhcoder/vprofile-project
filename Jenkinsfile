def COLOR_MAP = [
  'SUCCESS': 'good',
  'FAILURE': 'danger',
  ]

pipeline {
    
	agent any
	tools {
        maven "MAVEN3.9"
        jdk "JDK17"
        nodejs "NodeJS19"
    }
    environment {
        SNAP_REPO = 'vprofile-snapshot'
        NEXUS_USER = 'admin'
        NEXUS_PASS = 'admin!123'
        NEXUSIP = '10.0.35.182'
        NEXUSPORT = '8081'
        RELEASE_REPO = 'vprofile-release'
        NEXUS_CEN_REPO = 'vpro-maven-central'
	    NEXUS_GRP_REPO = 'vprofile-maven-group'
        NEXUS_LOGIN = 'nexuslogin'
        NEXUS_PASS = credentials('nexuspass')
        SONARSERVER = 'sonarserver'
        SONARSCANER = 'sonarscanner'
    }
	
    stages{
        
        stage('BUILD'){
            steps {
                sh 'mvn -s  settings.xml -DskipTests install'
            }
            post {
                success {
                    echo 'Now Archiving...'
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }
        stage('UNIT TEST'){
            steps {
                sh 'mvn -s  settings.xml test'
            }
        }
        stage ('CODE ANALYSIS WITH CHECKSTYLE'){
            steps {
                sh 'mvn -s  settings.xml checkstyle:checkstyle'
            }    
        }
        stage('CODE ANALYSIS with SONARQUBE') {
          
		  environment {
             scannerHome = tool "${SONARSCANER}"
          }

          steps {
            withSonarQubeEnv("${SONARSERVER}") {
               sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile-work \
                   -Dsonar.projectName=vprofile-work \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.libraries=target/vprofile-v2/WEB-INF/lib/*.jar \
                   -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
            }
          }
        }
         stage("Quality Gate") {
            steps {
             timeout(time: 10, unit: 'MINUTES') {
               waitForQualityGate abortPipeline: true
             }
            }
         }
      
         stage('NexusArtifactUploaderJob') {
            steps {
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
     stage('Ansible Deploy to Staging') {
        steps {
            ansiblePlaybook([
                playbook: 'ansible/site.yml',
                inventory: 'ansible/stage.inventory.yml',
                Installation: 'Ansible',
                colorized: true,
                credentialsId: 'applogin',
                disableHostKeyChecking: true,
                extraVars: [
                    USER: 'admin',
                    PASS: '${NEXUS_PASS}',
                    nexusip: '10.0.35.182'
                    reponame: 'vprofile-release',
                    groupid: 'QA',
                    time: "${env.BUILD_TIMESTAMP}",
                    build: "${env.BUILD_ID}"
                    artifactId: 'vproapp',
                    vprofile_version: "vproapp-${env.BUILD_ID}-${env.BUILD_TIMESTAMP}.war",
                ]
            ])
        }
   }
  post {
            always {
                echo 'Slack Notifications.'
                slackSend channel: '#jenkinscicd',
                    color: COLOR_MAP[currentBuild.currentResult],
                    message: "*${currentBuild.currentResult}:*Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
        }
    }
}