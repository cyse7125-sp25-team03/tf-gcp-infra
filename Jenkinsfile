void setBuildStatus(String message, String state) {
    def repoUrl = scm.getUserRemoteConfigs()[0].getUrl()
    
    echo "DEBUG: Repository URL detected: ${repoUrl}"
  step([
      $class: "GitHubCommitStatusSetter",
      reposSource: [$class: "ManuallyEnteredRepositorySource", url: repoUrl],
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/terraform-checks"],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}

pipeline {
    agent any
    
    options {
        timeout(time: 1, unit: 'HOURS')
        disableConcurrentBuilds()
    }
    
    stages {
        stage('Initialize Build') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-pat', usernameVariable: 'GITHUB_USERNAME', passwordVariable: 'GITHUB_TOKEN')]) {
                    setBuildStatus("Terraform check is starting...", "PENDING");
                }
            }
        }
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
                withCredentials([usernamePassword(credentialsId: 'github-pat', usernameVariable: 'GITHUB_USERNAME', passwordVariable: 'GITHUB_TOKEN')]) {
                    setBuildStatus("Terraform checks passed", "SUCCESS");
                }
        }
        failure {
            withCredentials([usernamePassword(credentialsId: 'github-pat', usernameVariable: 'GITHUB_USERNAME', passwordVariable: 'GITHUB_TOKEN')]) {
                setBuildStatus("Terraform checks failed", "FAILURE");
            }
        }
        always {
            cleanWs()
        }
    }
    }
}