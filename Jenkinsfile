pipeline {
    agent any

    environment {
        HARBOR_HOST = '192.168.56.20'
        IMAGE       = "${HARBOR_HOST}/vprofile/vproapp"
        TAG         = "${env.BUILD_NUMBER}"
        KUBECONFIG  = '/var/lib/jenkins/.kube/config'
    }

    stages {
        stage('Build image') {
            steps {
                sh "docker build -t ${IMAGE}:${TAG} -t ${IMAGE}:latest ."
            }
        }

        stage('Push to Harbor') {
            steps {
                sh '''
                    set -a; . /etc/harbor-creds.env; set +a
                    echo "$HARBOR_PASS" | docker login "$HARBOR_HOST" -u "$HARBOR_USER" --password-stdin
                '''
                sh "docker push ${IMAGE}:${TAG}"
                sh "docker push ${IMAGE}:latest"
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh "kubectl -n vprofile set image deployment/vproapp vproapp=${IMAGE}:${TAG}"
                sh "kubectl -n vprofile rollout status deployment/vproapp --timeout=180s"
            }
        }
    }

    post {
        always {
            sh 'docker image prune -f || true'
        }
    }
}
