pipeline{
    agent any
    tools{
        maven 'Maven3'
        jdk 'OracleJDK8'
    }

    environment{
        SANP_REPO = 'vprofile-snapshot'
        NEXUS_USER = 'admin'
        NEXUS_PASS = 'Admin@431'
        RELESASE_REPO = 'vprofile-release'
        CENTRAL_REPO = 'vpro-maven-central'
        NEXUS_IP = '172.31.25.180'
        NEXUS_PORT = '8081'
        NEXUS_GRP_REPO = 'vpro-maven-group'
        NEXUS_LOGIN='nexuslogin'
    stages{
        stage('Build'){
            steps{
                echo 'Building the project...'
                sh 'mvn -s settings.xml -DskipTests install'
            }
        }
        stage('Test'){
            steps{
                echo 'Testing the project...'
            }
        }
        stage('Deploy'){
            steps{
                echo 'Deploying the project...'
            }
        }
    } 
}
}