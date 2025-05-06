pipeline {
    agent { 
        label 'docker-slave' 
    }
    
    parameters {
        string(name: 'DOCKER_IMAGE', defaultValue: 'moe404/booster-django:latest', description: 'Docker image to deploy')
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
                
                // Log the pipeline start to audit trail
                sh "echo 'AUDIT: Pipeline started by ${currentBuild.getBuildCauses()[0].userId ?: 'SYSTEM'} at ${new Date()}' >> ${JENKINS_HOME}/audit-trail/terraform-audit.log"
                sh "echo 'AUDIT: Action requested: ${params.ACTION}' >> ${JENKINS_HOME}/audit-trail/terraform-audit.log"
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    
                    // Log the terraform init to audit trail
                    sh "echo 'AUDIT: Terraform init executed at ${new Date()}' >> ${JENKINS_HOME}/audit-trail/terraform-audit.log"
                }
            }
            post {
                success {
                    slackSend (color: 'good', message: "SUCCESSFUL: Stage 'Terraform Init' in Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'")
                    sh "echo 'AUDIT: Terraform init SUCCESS at ${new Date()}' >> ${JENKINS_HOME}/audit-trail/terraform-audit.log"
                }
                failure {
                    slackSend (color: 'danger', message: "FAILED: Stage 'Terraform Init' in Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'")
                    sh "echo 'AUDIT: Terraform init FAILED at ${new Date()}' >> ${JENKINS_HOME}/audit-trail/terraform-audit.log"
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                    
                    // Log the terraform plan to audit trail
                    sh "echo 'AUDIT: Terraform plan executed at ${new Date()}' >> ${JENKINS_HOME}/audit-trail/terraform-audit.log"
                }
            }
            post {
                success {
                    slackSend (color: 'good', message: "SUCCESSFUL: Stage 'Terraform Plan' in Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'")
                    sh "echo 'AUDIT: Terraform plan SUCCESS at ${new Date()}' >> ${JENKINS_HOME}/audit-trail/terraform-audit.log"
                }
                failure {
                    slackSend (color: 'danger', message: "FAILED: Stage 'Terraform Plan' in Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'")
                    sh "echo 'AUDIT: Terraform plan FAILED at ${new Date()}' >> ${JENKINS_HOME}/audit-trail/terraform-audit.log"
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
                        // Record the action in audit trail before execution
                        sh "echo 'AUDIT: Attempting Terraform ${params.ACTION} at ${new Date()}' >> ${JENKINS_HOME}/audit-trail/terraform-audit.log"
                        
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
                    sh "echo 'AUDIT: Terraform ${params.ACTION} SUCCESS at ${new Date()}' >> ${JENKINS_HOME}/audit-trail/terraform-audit.log"
                    
                    // For apply action, capture the created resources
                    script {
                        if (params.ACTION == 'apply') {
                            sh "terraform output > terraform_resources.txt || true"
                            sh "echo 'AUDIT: Resources created/modified:' >> ${JENKINS_HOME}/audit-trail/terraform-audit.log"
                            sh "cat terraform_resources.txt >> ${JENKINS_HOME}/audit-trail/terraform-audit.log || true"
                        }
                    }
                }
                failure {
                    slackSend (color: 'danger', message: "FAILED: Stage 'Terraform ${params.ACTION}' in Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'")
                    sh "echo 'AUDIT: Terraform ${params.ACTION} FAILED at ${new Date()}' >> ${JENKINS_HOME}/audit-trail/terraform-audit.log"
                }
            }
        }
    }
    
    post {
        always {
            // Archive the audit log as an artifact
            sh "mkdir -p ${WORKSPACE}/audit-logs || true"
            sh "cp ${JENKINS_HOME}/audit-trail/terraform-audit.log ${WORKSPACE}/audit-logs/ || true"
            archiveArtifacts artifacts: 'audit-logs/*', allowEmptyArchive: true
            
            // Log final pipeline status
            script {
                def status = currentBuild.result ?: 'SUCCESS'
                sh "echo 'AUDIT: Pipeline completed with status ${status} at ${new Date()}' >> ${JENKINS_HOME}/audit-trail/terraform-audit.log"
                sh "echo '---------------------------------------------' >> ${JENKINS_HOME}/audit-trail/terraform-audit.log"
            }
        }
        success {
            slackSend (color: 'good', message: "SUCCESSFUL: Terraform Pipeline '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }
        failure {
            slackSend (color: 'danger', message: "FAILED: Terraform Pipeline '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }
    }
}