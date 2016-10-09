PHONY: images dev-images up_db up_app setup_db volumes networks import_defualt-files

images: aldea_build cuenta_build dios_build kong_build;
aldea_image:
	pushd projects/aldea/ && make image && popd
cuenta_image:
	pushd projects/cuenta/ && make image && popd
dios_image:
	pushd projects/dios/ && make image && popd
kong_image:
	pushd projects/kong/ && make image && popd

dev-images: aldea_dev-image cuenta_dev-image dios_dev-image kong_dev-image;
aldea_dev-image:
	pushd projects/aldea/ && make dev-image && popd
cuenta_dev-image:
	pushd projects/cuenta/ && make dev-image && popd
dios_dev-image:
	pushd projects/dios/ && make dev-image && popd
kong_dev-image:
	pushd projects/kong/ && make dev-image && popd

up_db:
	docker-compose up -d aldea-database cuenta-database dios-database kong-database

up_app:
	docker-compose up -d aldea-application cuenta-application dios-application kong-application

setup_db: setup_aldea-db setup_cuenta-db setup_dios-db;
setup_aldea-db:
	docker-compose run --rm aldea-application bundle exec rails db:setup
setup_cuenta-db:
	docker-compose run --rm cuenta-application mix ecto.setup
setup_dios-db:
	docker-compose run --rm dios-application bundle exec rails db:setup

volumes:
	@docker volume create --name neeco_aldea || true
	@docker volume create --name neeco_cuenta || true
	@docker volume create --name neeco_dios || true
	@docker volume create --name neeco_kong || true
	@docker volume create --name neeco_public || true

networks: kong-networks dios-networks internal-networks
	@docker network create neeco_aldea || true
	@docker network create neeco_cuenta || true
	@docker network create neeco_dios || true
	@docker network create neeco_kong || true
kong-networks:
	@docker network create --internal neeco_kong-aldea || true
	@docker network create --internal neeco_kong-cuenta || true
dios-networks:
	@docker network create --internal neeco_dios-aldea || true
	@docker network create --internal neeco_dios-cuenta || true
	@docker network create --internal neeco_dios-kong || true
internal-networks:
	@docker network create --internal neeco_aldea-cuenta || true

import_default-files: volumes
	docker run --rm -i -v neeco_public:/work cuenta-application ash -c "cd /app/uploads/ && cp -r --parents images/users/defaults /work/"
