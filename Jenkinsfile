def COLOR_MAP = [
  'SUCCESS': 'good',
  'FAILURE': 'danger',
  ]

pipeline {
    
	agent any
    environment {
        NEXUS_PSW = credentials('nexuspass')
    }
	
    stages{
     stage('setup parameter') {
        steps {
            script {
                properties([ 
                    parameters([
                    string(defaultVale: '',
                        name: 'BUILD',
                        ),
                    string(defaultVale: '',
                        name: 'TIME',
                        )
                    ])
                ])
            }
        }
     }
     stage('Ansible Deploy to Staging') {
            steps {
                ansiblePlaybook([
                    playbook: 'ansible/site.yml',
                    inventory: 'ansible/prodinventory.yml',
                    installation: 'ansible',
                    colorized: true,
                    credentialsId: 'prodlogin',
                    disableHostKeyChecking: true,
                    extraVars: [
                        USER: 'admin',
                        PASS: '${NEXUS_PSW}',
                        nexusip: '10.0.35.182',
                        reponame: 'vprofile-release',
                        groupid: 'QA',
                        time: "${env.TIME}",
                        build: "${env.BUILD}",
                        artifactId: 'vproapp',
                        vprofile_version: "vproapp-${env.BUILD}-${env.TIME}.war"
                    ]
                ])
            }
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