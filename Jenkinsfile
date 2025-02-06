pipeline {
    agent any
    
    tools {
        terraform 'terraform-latest'
    }
    
    options {
        timeout(time: 1, unit: 'HOURS')
        disableConcurrentBuilds()
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        
        stage('Terraform Format Check') {
            steps {
                script {
                    def dirs = ['gcp-org', 'gcp-project-demo', 'gcp-project-dev', 'gcp-project-dns', 'modules']
                    
                    echo "Checking Terraform format for directories: ${dirs.join(', ')}"
                    
                    dirs.each { d ->
                        if (fileExists(d)) {
                            echo "Processing: ${d}"
                            dir(d) {
                                sh 'terraform fmt -check -recursive -diff'
                            }
                        } else {
                            echo "Skipping ${d} - does not exist!"
                        }
                    }
                }
            }
        }
        
        stage('Terraform Init & Validate') {
            steps {
                script {
                    def dirs = ['gcp-org', 'gcp-project-demo', 'gcp-project-dev', 'gcp-project-dns', 'modules']
                    dirs.each { d ->
                        if (fileExists(d)) {
                            echo "Validating: ${d}"
                            dir(d) {
                                sh '''
                                    terraform init -backend=false
                                    terraform validate
                                '''
                            }
                        } else {
                            echo "Skipping ${d} - does not exist!"
                        }
                    }
                }
            }
        }
    }
    
    post {
        success {
            step([
                $class: 'GitHubCommitStatusSetter',
                contextSource: [$class: 'ManuallyEnteredCommitContextSource', context: 'terraform-checks'],
                statusResultSource: [$class: 'ConditionalStatusResultSource', results: [
                    [$class: 'AnyBuildResult', message: 'Terraform format and validation passed', state: 'SUCCESS']
                ]]
            ])
        }
        failure {
            step([
                $class: 'GitHubCommitStatusSetter',
                contextSource: [$class: 'ManuallyEnteredCommitContextSource', context: 'terraform-checks'],
                statusResultSource: [$class: 'ConditionalStatusResultSource', results: [
                    [$class: 'AnyBuildResult', message: 'Terraform format or validation failed', state: 'FAILURE']
                ]]
            ])
            script {
                currentBuild.result = 'FAILURE'
            }
        }
        always {
            cleanWs()
        }
    }
}