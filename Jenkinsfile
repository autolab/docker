pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building..'
                sh 'ls -al'
                echo "user is: $USER"
                sh 'pwd'
                // comment out rebasing for now because we need to set up git credentials
              	sh 'cd Autolab && git rebase origin demosite-patches && cd ..'
                sh 'grep /etc/group -e "docker"'
                sh 'make'
                sh 'docker stop rabbitmq || true && docker rm rabbitmq || true'
                sh 'docker-compose build'
                sh 'docker-compose up -d'
                sh 'make ci-set-perms'
                sh 'make ci-db-migrate'
                // change the Tango volume path
                sh 'python3 ci_script.py -v ./docker-compose.yml'
                sh 'docker-compose stop'
                // configure SSL
                sh 'make ssl'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}