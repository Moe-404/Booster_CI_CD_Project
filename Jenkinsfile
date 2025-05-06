pipeline {
    agent { label 'docker-slave' }
    
    parameters {
        string(name: 'DOCKER_IMAGE', defaultValue: 'yourusername/booster-django:latest', description: 'Docker image to deploy')
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action to perform')
    }
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        TF_VAR_docker_image = "${params.DOCKER_IMAGE}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                slackSend (color: '#FFFF00', message: "STARTED: Terraform Pipeline '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
            post {
                success {
                    slackSend (color: 'good', message: "SUCCESSFUL: Stage 'Terraform Init' in Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'")
                }
                failure {
                    slackSend (color: 'danger', message: "FAILED: Stage 'Terraform Init' in Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'")
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                }
            }
            post {
                success {
                    slackSend (color: 'good', message: "SUCCESSFUL: Stage 'Terraform Plan' in Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'")
                }
                failure {
                    slackSend (color: 'danger', message: "FAILED: Stage 'Terraform Plan' in Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'")
                }
            }
        }
        
        stage('Terraform Apply/Destroy') {
            when {
                expression { params.ACTION == 'apply' || params.ACTION == 'destroy' }
            }
            steps {
                dir('terraform') {
                    script {
                        if (params.ACTION == 'apply') {
                            sh 'terraform apply -auto-approve tfplan'
                        } else if (params.ACTION == 'destroy') {
                            sh 'terraform destroy -auto-approve'
                        }
                    }
                }
            }
            post {
                success {
                    slackSend (color: 'good', message: "SUCCESSFUL: Stage 'Terraform ${params.ACTION}' in Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'")
                }
                failure {
                    slackSend (color: 'danger', message: "FAILED: Stage 'Terraform ${params.ACTION}' in Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'")
                }
            }
        }
    }
    
    post {
        success {
            slackSend (color: 'good', message: "SUCCESSFUL: Terraform Pipeline '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }
        failure {
            slackSend (color: 'danger', message: "FAILED: Terraform Pipeline '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }
    }
}
