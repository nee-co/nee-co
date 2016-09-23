build: kong_build aldea_build cuenta_build dios_build

kong_build:
	pushd projects/kong/ && make build && popd

aldea_build:
	pushd projects/aldea/ && make build && popd

cuenta_build:
	pushd projects/cuenta/ && make build && popd

dios_build:
	pushd projects/dios/ && make build && popd

dev-build: kong_dev-build aldea_dev-build cuenta_dev-build dios_dev-build

kong_dev-build:
	pushd projects/kong/ && make dev-build && popd

aldea_dev-build:
	pushd projects/aldea/ && make dev-build && popd

cuenta_dev-build:
	pushd projects/cuenta/ && make dev-build && popd

dios_dev-build:
	pushd projects/dios/ && make dev-build && popd

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

import_default_image:
	docker run --rm -it -v $(PWD)/public/images/users/:/work cuenta-application cp -r /app/uploads/images/users/defaults/ /work/
