pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        ECR_CREDENTIALS = credentials('aws-ecr-credentials')
        AWS_REGION = 'ap-south-1'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        REPO_NAME = "studentsphere"
    }

    stages {
        stage('Git Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Backend Maven Build') {
            steps {
                dir('backend') {
                    sh './mvnw clean package -DskipTests'
                }
            }
        }

        stage('Frontend Build') {
            steps {
                dir('frontend') {
                    sh 'npm ci --force'
                    sh 'npm run build'
                }
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh 'trivy fs --exit-code 1 --severity HIGH,CRITICAL ./'
            }
        }

        stage('Docker Build') {
            steps {
                // Backend Docker Image
                sh "docker build -t ${DOCKERHUB_CREDENTIALS_USR}/studentsphere-backend:${IMAGE_TAG} -f backend/dockerfile backend/"
                sh "docker build -t ${DOCKERHUB_CREDENTIALS_USR}/studentsphere-frontend:${IMAGE_TAG} -f frontend/dockerfile frontend/"
                
                // Tag for ECR also
                sh "docker tag ${DOCKERHUB_CREDENTIALS_USR}/studentsphere-backend:${IMAGE_TAG} ${ECR_CREDENTIALS_USR}.dkr.ecr.${AWS_REGION}.amazonaws.com/studentsphere-backend:${IMAGE_TAG}"
                sh "docker tag ${DOCKERHUB_CREDENTIALS_USR}/studentsphere-frontend:${IMAGE_TAG} ${ECR_CREDENTIALS_USR}.dkr.ecr.${AWS_REGION}.amazonaws.com/studentsphere-frontend:${IMAGE_TAG}"
            }
        }

        stage('Docker Push to DockerHub') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh "docker push ${DOCKERHUB_CREDENTIALS_USR}/studentsphere-backend:${IMAGE_TAG}"
                sh "docker push ${DOCKERHUB_CREDENTIALS_USR}/studentsphere-frontend:${IMAGE_TAG}"
            }
        }

        stage('Docker Push to AWS ECR') {
            steps {
                sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_CREDENTIALS_USR}.dkr.ecr.${AWS_REGION}.amazonaws.com
                '''
                sh "docker push ${ECR_CREDENTIALS_USR}.dkr.ecr.${AWS_REGION}.amazonaws.com/studentsphere-backend:${IMAGE_TAG}"
                sh "docker push ${ECR_CREDENTIALS_USR}.dkr.ecr.${AWS_REGION}.amazonaws.com/studentsphere-frontend:${IMAGE_TAG}"
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh """
                    kubectl set image deployment/studentsphere-backend backend=${ECR_CREDENTIALS_USR}.dkr.ecr.${AWS_REGION}.amazonaws.com/studentsphere-backend:${IMAGE_TAG} -n student-app || echo 'Deployment not found yet'
                    kubectl set image deployment/studentsphere-frontend frontend=${ECR_CREDENTIALS_USR}.dkr.ecr.${AWS_REGION}.amazonaws.com/studentsphere-frontend:${IMAGE_TAG} -n student-app || echo 'Deployment not found yet'
                """
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
