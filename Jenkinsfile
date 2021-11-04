/*

Prerequisites for the host machine:

- Make sure jenkins is a docker of docker.
  Run `grep /etc/group -e docker` and make sure "jenkins" is in there.

- Give jenkins administrator access. This is necessary as restoring changes from previous deployments and initializing
  ssl requires sudo access.
  Add `jenkins ALL=(ALL) NOPASSWD: ALL` to `/etc/sudoers`.

*/

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
                sh 'git config --global user.email "autolab.bot@gmail.com"'
                sh 'git config --global user.name "jenkinsBot"'
              	sh 'cd Autolab && sudo chown $USER db/schema.rb && sudo git restore db/schema.rb && git rebase origin/demosite-patches && cd ..'
                sh 'grep /etc/group -e "docker"'
                sh 'make clean && make'
                sh 'docker stop autolab_ci|| true && docker rm autolab_ci || true'
                sh 'docker stop tango_ci|| true && docker rm tango_ci || true'
                sh 'docker-compose build'
            }
        }
        stage('Configure SSL') {
            steps {
                echo 'Configuring SSL...'
                sh 'docker-compose up -d'
                sh 'make ci-set-perms'
                sh 'make ci-db-migrate'
                // change the Tango volume path
                sh 'python3 ci_script.py -v .env'
                sh 'docker-compose stop'
                // configure SSL
                sh "python3 ci_script.py -a nginx/app.conf"
                sh 'make ssl'
                sh 'python3 ci_script.py -s ./ssl/init-letsencrypt.sh'
                // nuke any previous certificates
                sh 'rm -rf /var/lib/jenkins/workspace/autolab-demo-test/ssl/certbot/conf/live/nightly.autolabproject.com*'
                sh "echo 'n' | echo 'y' | sudo sh ./ssl/init-letsencrypt.sh"
            }
        }
        stage('Deploy') {
            steps {
            	echo 'Deploying nightly.autolabproject.com...'
                // build autograding images
                sh "docker build -t autograding_image Tango/vmms/"
                // bring everything up!
                sh "docker-compose up -d"
                sh "curl -X POST -H 'Content-type: application/json' --data "{'text':'nightly.autolabproject.com deployed successfully.'}" htt"
            }
        }
    }
}