.PHONY: images up_proxy up_db up_app setup_db volumes networks import_defualt-files cert

images: aldea_image caja_image cuenta_image dios_image kong_image;
aldea_image:
	pushd projects/aldea/ && make image && popd
caja_image:
	pushd projects/caja/ && make image && popd
cuenta_image:
	pushd projects/cuenta/ && make image && popd
dios_image:
	pushd projects/dios/ && make image && popd
kong_image:
	pushd projects/kong/ && make image && popd

up_proxy:
	docker-compose up -d puerta

up_db:
	docker-compose up -d aldea-database caja-database cuenta-database dios-database kong-database

up_app:
	docker-compose up -d aldea-application caja-application cuenta-application dios-application kong-application

setup_db: setup_aldea-db setup_cuenta-db setup_dios-db;
setup_aldea-db:
	pushd projects/aldea/ && make setup_db && popd
setup_cuenta-db:
	pushd projects/cuenta/ && make setup_db && popd
setup_dios-db:
	pushd projects/dios/ && make setup_db && popd

volumes:
	@docker volume create --name neeco_aldea || true
	@docker volume create --name neeco_caja || true
	@docker volume create --name neeco_cuenta || true
	@docker volume create --name neeco_dios || true
	@docker volume create --name neeco_kong || true
	@docker volume create --name neeco_public || true

networks: puerta-networks kong-networks dios-networks internal-networks
	@docker network create neeco_aldea || true
	@docker network create neeco_caja || true
	@docker network create neeco_cuenta || true
	@docker network create neeco_dios || true
	@docker network create neeco_kong || true
	@docker network create neeco_puerta || true
puerta-networks:
	@docker network create --internal neeco_puerta-kong || true
	@docker network create --internal neeco_puerta-dios || true
kong-networks:
	@docker network create --internal neeco_kong-aldea || true
	@docker network create --internal neeco_kong-caja || true
	@docker network create --internal neeco_kong-cuenta || true
dios-networks:
	@docker network create --internal neeco_dios-aldea || true
	@docker network create --internal neeco_dios-caja || true
	@docker network create --internal neeco_dios-cuenta || true
	@docker network create --internal neeco_dios-kong || true
internal-networks:
	@docker network create --internal neeco_aldea-cuenta || true
	@docker network create --internal neeco_caja-cuenta || true

import_default-files: volumes
	docker run --rm -i -v neeco_public:/work cuenta-application ash -c "cd /app/uploads/ && cp -r --parents images/users/defaults /work/"

cert:
	docker run -it --rm \
  -p 80:80 -p 443:443 \
  -v /etc/letsencrypt:/etc/letsencrypt \
  quay.io/letsencrypt/letsencrypt:latest certonly \
  --standalone --agree-tos -m nhac.neeco@gmail.com \
  -d neec.ooo -d api.neec.ooo -d admin.neec.ooo
