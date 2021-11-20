/*

Prerequisites for the host machine:

- Make sure jenkins is an user of docker.
  Run `grep /etc/group -e docker` and make sure "jenkins" is in there.

- Give jenkins administrator access. This is necessary as restoring changes from previous deployments and initializing
  ssl requires sudo access.
  Add `jenkins ALL=(ALL) NOPASSWD: ALL` to `/etc/sudoers`.

- Make sure that the host machine has credentials (autolab.bot) to pull and rebase the latest Autolab repos.

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
                // nuke any previous certificates, typically not necessary
                // openSSL only allows 5 new certificates for a domain in a week
                // sh 'sudo rm -rf /var/lib/jenkins/workspace/autolab-demo-test/ssl/certbot/conf/live/nightly.autolabproject.com*'
                sh 'docker stop autolab || true && docker rm autolab || true'
                sh 'docker stop tango || true && docker rm tango || true'
                sh 'docker stop redis || true && docker rm redis || true'
                sh 'docker stop mysql || true && docker rm mysql || true'
                sh 'docker stop certbot || true && docker rm certbot || true'
                sh 'docker-compose build'
            }
        }
        stage('Configure SSL') {
            steps {
                echo 'Configuring SSL...'
                sh 'docker-compose up -d'
                sh 'make set-perms'
                sh 'make db-migrate'
                // create initial user
                sh 'docker exec autolab env RAILS_ENV=production bundle exec rails admin:create_root_user[admin@demo.bar,"adminfoobar","Admin","Foo"] || true'
                // change the Tango volume path
                sh 'python3 ci_script.py -v .env'
                sh 'docker-compose stop'
                // configure SSL
                sh "python3 ci_script.py -a nginx/app.conf"
                sh 'make ssl'
                sh 'python3 ci_script.py -s ./ssl/init-letsencrypt.sh'
                // do not replace existing certificate
                sh "echo 'n' | echo 'N' | sudo sh ./ssl/init-letsencrypt.sh"
            }
        }
        stage('Deploy') {
            steps {
            	echo 'Deploying nightly.autolabproject.com...'
                // build autograding images
                sh "docker build -t autograding_image Tango/vmms/"
                // bring everything up!
                sh "docker-compose up -d"
            }
        }
    }
}