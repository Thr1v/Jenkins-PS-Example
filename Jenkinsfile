pipeline {
    agent { label 'windows' }  // change to your Windows agent label

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '30'))
    }

    triggers {
        // Nightly-ish at 02:00
        cron('H 2 * * *')
    }

    parameters {
        string(name: 'LOG_PATH',       defaultValue: 'C:\\Logs', description: 'Path to scan')
        string(name: 'DAYS_THRESHOLD', defaultValue: '14',       description: 'Age threshold in days')
        string(name: 'EMAIL_TO',       defaultValue: 'ops-team@example.com', description: 'Notification recipients')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Run log metrics script') {
            steps {
                powershell '''
                    $ErrorActionPreference = "Stop"
                    
                    $LogPath = $env:LOG_PATH
                    $days    = [int]$env:DAYS_THRESHOLD

                    Write-Host "Using $LogPath log path"
                    Write-Host "$days left on the threshold"
                    
                    ./log-metrics.ps1 -LogPath $LogPath -DaysThreshold $days
                '''
            }
        }

        stage('Archive report') {
            steps {
                archiveArtifacts artifacts: 'reports/*.csv', fingerprint: true
            }
        }
    }

    post {
        success {
            echo "Log metrics job completed successfully."

            emailext(
                to: "${params.EMAIL_TO}",
                subject: "SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """Log metrics job completed successfully.

Job: ${env.JOB_NAME}
Build: #${env.BUILD_NUMBER}
Result: SUCCESS

You can view the build at: ${env.BUILD_URL}""",
                attachLog: true,
                compressLog: true,
                attachmentsPattern: 'reports/*.csv'
            )
        }
        failure {
            echo "Log metrics job failed. Sending failure email."

            emailext(
                to: "${params.EMAIL_TO}",
                subject: "FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """Log metrics job FAILED.

Job: ${env.JOB_NAME}
Build: #${env.BUILD_NUMBER}
Result: FAILURE

Please check the console log: ${env.BUILD_URL}console""",
                attachLog: true,
                compressLog: true,
                attachmentsPattern: 'reports/*.csv'
            )
        }
    }
}
