up_db:
	docker-compose up -d kong-database cuenta-database aldea-database dios-database

up_app:
	docker-compose up -d kong-application cuenta-application aldea-application dios-application

setup_db: setup_cuenta_db setup_aldea_db setup_dios_db

setup_cuenta_db:
	docker-compose run --rm cuenta-application mix ecto.setup

setup_aldea_db:
	docker-compose run --rm aldea-application bundle exec rails db:setup

setup_dios_db:
	docker-compose run --rm dios-application bundle exec rails db:setup
