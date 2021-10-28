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
                // need to restore the schema.db which is changed from the previous deployment
              	sh 'cd Autolab && sudo git restore . && git rebase origin demosite-patches && cd ..'
                sh 'grep /etc/group -e "docker"'
                sh 'make clean && make'
                sh 'docker stop autolab_ci|| true && docker rm autolab_ci || true'
                sh 'docker stop tango_ci|| true && docker rm tango_ci || true'
                sh 'docker-compose build'
                sh 'docker-compose up -d'
                sh 'make ci-set-perms'
                sh 'make ci-db-migrate'
                // change the Tango volume path
                sh 'python3 ci_script.py -v ./docker-compose.yml'
                sh 'docker-compose stop'
                // configure SSL
                sh 'make ssl'
                sh 'python3 ci_script.py -s ./ssl/init-letsencrypt.sh'
                sh "echo 'n' | echo 'y' | sudo sh ./ssl/init-letsencrypt.sh"
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