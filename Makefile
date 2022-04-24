all: setup-autolab-configs setup-tango-configs

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
	echo "Creating default Tango/config.py"
	cp -n ./Tango/config.template.py ./Tango/config.py

.PHONY: db-migrate
db-migrate:
	docker exec autolab bash /home/app/webapp/docker/db_migrate.sh

.PHONY: update
update:
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

.PHONY: ssl
ssl:
	cp -n ./ssl/init-letsencrypt.sh.template ./ssl/init-letsencrypt.sh
	cp -n ./nginx/app.conf.template ./nginx/app.conf

.PHONY: no-ssl
no-ssl:
	cp -n ./nginx/no-ssl-app.conf.template ./nginx/no-ssl-app.conf


.PHONY: clean
clean:
	rm -rf ./Autolab/config/database.yml
	rm -rf ./Autolab/config/school.yml
	rm -rf ./Autolab/config/environments/production.rb
	rm -rf ./Autolab/config/autogradeConfig.rb
	rm -rf ./Tango/config.py
	rm -rf ./ssl/init-letsencrypt.sh
	rm -rf ./Autolab/log
	rm -rf ./.env
	# We don't remove Autolab/courses here, as it may contain important user data. Remove it yourself manually if needed.
