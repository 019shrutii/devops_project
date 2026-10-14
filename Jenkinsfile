
pipeline {
    agent any

    environment {
        IMAGE_NAME = 'shruti190/ui'
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
    }

    post {
        success {
            echo 'UI Docker image built and pushed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check Jenkins Console Output.'
        }
    }
}

