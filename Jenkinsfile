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
        NEXUS_LOGIN = 'nexuslogin'
    }

    stages {
        stage('Build') {
            steps {
                sh '''
                    sed -i 's|\\${NEXUS_GRP_REPO}|'"$NEXUS_GRP_REPO"'|g' settings.xml
                    sed -i 's|\\${CENTRAL_REPO}|'"$CENTRAL_REPO"'|g' settings.xml
                    sed -i 's|\\${NEXUSIP}|'"$NEXUSIP"'|g' settings.xml
                    sed -i 's|\\${NEXUSPORT}|'"$NEXUSPORT"'|g' settings.xml
                    sed -i 's|\\${NEXUS_USER}|'"$NEXUS_USER"'|g' settings.xml
                    sed -i 's|\\${NEXUS_PASS}|'"$NEXUS_PASS"'|g' settings.xml
                    sed -i 's|\\${SNAP_REPO}|'"$SNAP_REPO"'|g' settings.xml
                    sed -i 's|\\${RELEASE_REPO}|'"$RELEASE_REPO"'|g' settings.xml

                    mvn -s settings.xml -DskipTests install
                '''
            }
        }
    }
}
