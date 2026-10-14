// pipeline {
//     agent any

//     environment {
//         IMAGE_NAME = 'shruti190/ui'
//     }

//     stages {
//         stage('GIT CHECKOUT') {
//             steps {
//                 git branch: 'main',
//                     url: 'https://github.com/019shrutii/devops_project.git'
//             }
//         }

//         stage('BUILD DOCKER IMAGE') {
//             steps {
//                 sh '''
//                     docker build \
//                         -t "$IMAGE_NAME:$BUILD_NUMBER" \
//                         -t "$IMAGE_NAME:latest" .
//                 '''
//             }
//         }

//         stage('PUSH IMAGE TO DOCKERHUB') {
//             steps {
//                 withCredentials([
//                     usernamePassword(
//                         credentialsId: 'dockerhub-creds',
//                         usernameVariable: 'DOCKER_USER',
//                         passwordVariable: 'DOCKER_PASS'
//                     )
//                 ]) {
//                     sh '''
//                         set +x
//                         set -eu

//                         echo "$DOCKER_PASS" | docker login \
//                             --username "$DOCKER_USER" \
//                             --password-stdin

//                         trap 'docker logout >/dev/null 2>&1 || true' EXIT

//                         docker push "$IMAGE_NAME:$BUILD_NUMBER"
//                         docker push "$IMAGE_NAME:latest"
//                     '''
//                 }
//             }
//         }
//     }

//     post {
//         success {
//             echo 'UI Docker image built and pushed successfully!'
//         }
//         failure {
//             echo 'Pipeline failed. Check Jenkins Console Output.'
//         }
//     }
// }


pipeline {
    agent any

    environment {
        IMAGE_NAME = 'shruti190/ui'
        AWS_REGION = 'eu-west-1'
        EKS_CLUSTER = 'devops-eks'
        K8S_DEPLOYMENT = 'devops-ui-deployment'
        K8S_CONTAINER = 'devops-ui'
    }

    stages {
        stage('GIT CHECKOUT') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/019shrutii/devops_project.git'
            }
        }

        stage('BUILD DOCKER IMAGE') {
            steps {
                sh '''
                    set -eu
                    docker build \
                        -t "$IMAGE_NAME:$BUILD_NUMBER" \
                        -t "$IMAGE_NAME:latest" .
                '''
            }
        }

        stage('PUSH IMAGE TO DOCKERHUB') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh '''
                        set +x
                        set -eu

                        echo "$DOCKER_PASS" | docker login \
                            --username "$DOCKER_USER" \
                            --password-stdin

                        trap 'docker logout >/dev/null 2>&1 || true' EXIT

                        docker push "$IMAGE_NAME:$BUILD_NUMBER"
                        docker push "$IMAGE_NAME:latest"
                    '''
                }
            }
        }

        stage('DEPLOY TO EKS') {
            steps {
                sh '''
                    set -eu

                    echo "Applying Kubernetes manifests..."

                    # Use this build's immutable image tag
                    sed -i \
                      "s|image: shruti190/ui:latest|image: ${IMAGE_NAME}:${BUILD_NUMBER}|" \
                      deployment.yml

                    kubectl apply -f deployment.yml
                    kubectl apply -f service.yml

                    echo "Waiting for rollout..."

                    kubectl rollout status \
                      deployment/"$K8S_DEPLOYMENT" \
                      --timeout=180s

                    echo "Current pods:"
                    kubectl get pods -o wide

                    echo "Current service:"
                    kubectl get service devops-ui-service
                '''
            }
        }
    }

    post {
        success {
            echo 'Build, Docker Hub push, and EKS deployment succeeded!'
        }
        failure {
            echo 'Pipeline failed. Check Console Output to identify the failed stage.'
        }
    }
}

