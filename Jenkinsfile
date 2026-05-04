pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "adityas0987/java-app"
        DOCKER_TAG   = "${BUILD_NUMBER}"
        SONAR_PROJECT = "java-app"
    }

    tools {
        maven 'Maven3'         // name configured in Jenkins tools
        jdk   'JDK17'          // name configured in Jenkins tools
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/adityas0987/helloworld.git',
                    credentialsId: 'github-creds'   // optional for public repos
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -Dmaven.test.skip=true'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('sonarqube') {   // name from Jenkins system config
                    sh 'mvn sonar:sonar -Dsonar.projectKey=${SONAR_PROJECT}'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build & Push') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'dockerhub-creds',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
        )]) {
            sh '''
                docker build -t ''' + env.DOCKER_IMAGE + ':' + env.BUILD_NUMBER + ''' .
                docker tag ''' + env.DOCKER_IMAGE + ':' + env.BUILD_NUMBER + ' ' + env.DOCKER_IMAGE + ''':latest
                echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                docker push ''' + env.DOCKER_IMAGE + ':' + env.BUILD_NUMBER + '''
                docker push ''' + env.DOCKER_IMAGE + ''':latest
            '''
        }
    }
}

        stage('Deploy to Kubernetes') {
    steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
            sh '''
                kubectl apply -f k8s/deployment.yaml
                kubectl rollout status deployment/java-app --timeout=120s
            '''
        }
    }
}
    }

    post {
        success { echo 'Pipeline succeeded! App deployed.' }
        failure { echo 'Pipeline failed. Check logs.' }
    }
}