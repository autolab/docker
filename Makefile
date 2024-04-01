all: setup-autolab-configs setup-tango-configs setup-docker-configs setup-config-ymls initialize_secrets
update: update-repos setup-config-ymls initialize_secrets

.PHONY: setup-autolab-configs
setup-autolab-configs:
	@echo "Creating default Autolab/config/database.yml"
	cp -n ./Autolab/config/database.docker.yml ./Autolab/config/database.yml

	@echo "Creating default Autolab/config/school.yml"
	cp -n ./Autolab/config/school.yml.template ./Autolab/config/school.yml

	@echo "Creating default Autolab/config/environments/production.rb"
	cp -n ./Autolab/config/environments/production.rb.template ./Autolab/config/environments/production.rb

	@echo "Creating default .env"
	cp -n ./.env.template ./.env

	@echo "Creating default Autolab/config/autogradeConfig.rb"
	cp -n ./Autolab/config/autogradeConfig.rb.template ./Autolab/config/autogradeConfig.rb

	@echo "Creating default Autolab/courses"
	mkdir -p ./Autolab/courses

.PHONY: setup-tango-configs
setup-tango-configs:
	@echo "Creating default Tango/config.py"
	cp -n ./Tango/config.template.py ./Tango/config.py

.PHONY: setup-docker-configs
setup-docker-configs:
	@echo "Creating default ssl/init-letsencrypt.sh"
	cp -n ./ssl/init-letsencrypt.sh.template ./ssl/init-letsencrypt.sh
	@echo "Creating default nginx/app.conf"
	cp -n ./nginx/app.conf.template ./nginx/app.conf
	@echo "Creating default nginx/no-ssl-app.conf"
	cp -n ./nginx/no-ssl-app.conf.template ./nginx/no-ssl-app.conf

.PHONY: setup-config-ymls
setup-config-ymls:
	@echo "Creating default oauth_config.yml"
	touch ./Autolab/config/oauth_config.yml

	@echo "Creating default smtp_config.yml"
	touch ./Autolab/config/smtp_config.yml

	@echo "Creating default github_config.yml"
	touch ./Autolab/config/github_config.yml

	@echo "Creating default lti_config.yml"
	touch ./Autolab/config/lti_config.yml

	@echo "Creating default lti_platform_jwk.json"
	touch ./Autolab/config/lti_platform_jwk.json

	@echo "Creating default lti_tool_jwk.json"
	touch ./Autolab/config/lti_tool_jwk.json

.PHONY: initialize_secrets
initialize_secrets:
	@echo Initializing docker and tango secret keys.
	./initialize_secrets.sh

.PHONY: db-migrate
db-migrate:
	docker exec autolab bash /home/app/webapp/docker/db_migrate.sh

.PHONY: update-repos
update-repos:
	@echo Pulling Autolab and Tango repositories.
	cd ./Autolab && git checkout master && git pull origin master
	cd ..
	cd ./Tango && git checkout master && git pull origin master
	cd ..

.PHONY: set-perms
set-perms:
	docker exec autolab chown -R app:app /home/app/webapp

.PHONY: create-user
create-user:
	docker exec -it autolab bash /home/app/webapp/bin/initialize_user.sh

.PHONY: clean
clean:
	@echo "Deleting all Autolab, Tango, SSL, Nginx, Docker Compose deployment configs"
	rm -rf ./Autolab/config/database.yml
	rm -rf ./Autolab/config/school.yml
	rm -rf ./Autolab/config/environments/production.rb
	rm -rf ./Autolab/config/autogradeConfig.rb
	rm -rf ./Autolab/config/oauth_config.yml
	rm -rf ./Autolab/config/smtp_config.yml
	rm -rf ./Autolab/config/github_config.yml
	rm -rf ./Autolab/config/lti_config.yml
	rm -rf ./Autolab/config/lti_platform_jwk.json
	rm -rf ./Autolab/config/lti_tool_jwk.json
	rm -rf ./Tango/config.py
	rm -rf ./ssl/init-letsencrypt.sh
	rm -rf ./nginx/app.conf
	rm -rf ./nginx/no-ssl-app.conf
	rm -rf ./Autolab/log
	rm -rf ./.env
	# We don't remove Autolab/courses here, as it may contain important user data. Remove it yourself manually if needed.
