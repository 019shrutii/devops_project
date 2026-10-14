pipeline {
    agent any

    stages {
        stage('Git Clone') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        docker build -t "$DOCKER_USER/devops-lab:$BUILD_NUMBER" .
                        docker tag "$DOCKER_USER/devops-lab:$BUILD_NUMBER" "$DOCKER_USER/devops-lab:latest"
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push "$DOCKER_USER/devops-lab:$BUILD_NUMBER"
                        docker push "$DOCKER_USER/devops-lab:latest"
                    '''
                }
            }
        }
    }
}

