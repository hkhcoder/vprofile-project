pipeline {
    agent any

    tools {
        jdk "JDK17"
        maven "MAVEN3.9"
    }

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: "20"))
    }

    environment {
        APP_NAME = "vprofile"
        OPENSHIFT_NAMESPACE = "vprofile"
        OPENSHIFT_API_URL = "https://api.openshift.example.com:6443"
        OPENSHIFT_TOKEN_CREDENTIAL_ID = "openshift-token"

        // Existing Tekton Pipeline in OpenShift that implements build/push/deploy GitOps flow.
        TEKTON_PIPELINE_NAME = "vprofile-gitops"
        TEKTON_SERVICE_ACCOUNT = "pipeline"

        // GitOps repo details passed to Tekton as params.
        GITOPS_REPO_URL = "https://github.com/your-org/vprofile-gitops.git"
        GITOPS_BRANCH = "main"
        GITOPS_MANIFEST_PATH = "apps/vprofile/overlays/prod"
    }

    stages {
        stage("Checkout") {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(script: "git rev-parse --short=8 HEAD", returnStdout: true).trim()
                    env.IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT_SHORT}"
                    env.PIPELINE_RUN_NAME = "${env.APP_NAME}-${env.BUILD_NUMBER}"
                }
                echo "Commit: ${env.GIT_COMMIT_SHORT}"
                echo "Image tag: ${env.IMAGE_TAG}"
            }
        }

        stage("Build and Test") {
            steps {
                sh "mvn -B -ntp clean verify"
            }
            post {
                always {
                    junit testResults: "target/surefire-reports/*.xml", allowEmptyResults: true
                    archiveArtifacts artifacts: "target/*.war", allowEmptyArchive: true
                }
            }
        }

        stage("Trigger OpenShift PipelineRun (GitOps)") {
            steps {
                withCredentials([string(credentialsId: "${OPENSHIFT_TOKEN_CREDENTIAL_ID}", variable: "OCP_TOKEN")]) {
                    sh '''
                        set -euo pipefail

                        oc login "${OPENSHIFT_API_URL}" --token="${OCP_TOKEN}" --insecure-skip-tls-verify=true
                        oc project "${OPENSHIFT_NAMESPACE}"

                        cat > pipelinerun.yaml <<EOF
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: ${PIPELINE_RUN_NAME}
  namespace: ${OPENSHIFT_NAMESPACE}
  labels:
    app.kubernetes.io/name: ${APP_NAME}
    app.kubernetes.io/managed-by: jenkins
spec:
  pipelineRef:
    name: ${TEKTON_PIPELINE_NAME}
  serviceAccountName: ${TEKTON_SERVICE_ACCOUNT}
  params:
    - name: app-name
      value: ${APP_NAME}
    - name: source-repo-url
      value: ${GIT_URL}
    - name: source-revision
      value: ${GIT_COMMIT}
    - name: image-tag
      value: ${IMAGE_TAG}
    - name: gitops-repo-url
      value: ${GITOPS_REPO_URL}
    - name: gitops-repo-branch
      value: ${GITOPS_BRANCH}
    - name: gitops-manifest-path
      value: ${GITOPS_MANIFEST_PATH}
EOF

                        oc apply -f pipelinerun.yaml
                        oc wait --for=condition=Succeeded --timeout=60m "pipelinerun/${PIPELINE_RUN_NAME}" || true

                        STATUS="$(oc get pipelinerun "${PIPELINE_RUN_NAME}" -o jsonpath='{.status.conditions[0].status}')"
                        REASON="$(oc get pipelinerun "${PIPELINE_RUN_NAME}" -o jsonpath='{.status.conditions[0].reason}')"
                        MESSAGE="$(oc get pipelinerun "${PIPELINE_RUN_NAME}" -o jsonpath='{.status.conditions[0].message}')"

                        echo "PipelineRun status=${STATUS} reason=${REASON}"
                        [ -n "${MESSAGE}" ] && echo "${MESSAGE}" || true

                        if [ "${STATUS}" != "True" ]; then
                          echo "Tekton task statuses:"
                          oc get taskrun -l tekton.dev/pipelineRun="${PIPELINE_RUN_NAME}" -o wide || true
                          exit 1
                        fi
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "GitOps delivery completed. OpenShift PipelineRun: ${env.PIPELINE_RUN_NAME}"
        }
        failure {
            echo "Pipeline failed. Inspect Jenkins logs and Tekton TaskRuns in namespace ${env.OPENSHIFT_NAMESPACE}."
        }
        always {
            cleanWs deleteDirs: true, disableDeferredWipeout: true
        }
    }
}
