pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building..'
                sh 'ls -al'
                echo "user is: $USER"
                sh 'pwd'
                sh 'cd Autolab && git checkout demosite-patches && cd ..'
                sh 'grep /etc/group -e "docker"'
                sh 'make'
                sh 'docker-compose build'
                sh 'docker-compose up -d'
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