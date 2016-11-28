.PHONY: proxy db app seed migrate volumes networks import_defualt-files cert htpasswd

proxy:
	docker-compose up -d puerta

db:
	docker-compose up -d aldea-database cadena-database cuenta-database dios-database kong-database

app:
	docker-compose up -d aldea-application cadena-application cuenta-application dios-application kong-application

seed: seed-aldea seed-cuenta seed-dios;
seed-aldea:
	docker-compose run --rm aldea-application bundle exec rails db:seed
seed-cuenta:
	docker-compose run --rm cuenta-application mix ecto.seed
seed-dios:
	docker-compose run --rm dios-application bundle exec rails db:seed

migrate: migrate-aldea migrate-cuenta migrate-dios;
migrate-aldea:
	docker-compose run --rm aldea-application bundle exec rails db:migrate
migrate-cuenta:
	docker-compose run --rm cuenta-application mix ecto.migrate
migrate-dios:
	docker-compose run --rm dios-application bundle exec rails db:migrate

volumes:
	@docker volume create --name neeco_aldea || true
	@docker volume create --name neeco_cadena || true
	@docker volume create --name neeco_cuenta || true
	@docker volume create --name neeco_dios || true
	@docker volume create --name neeco_kong || true
	@docker volume create --name neeco_images || true

networks: puerta-networks kong-networks dios-networks imagen-networks internal-networks
	@docker network create neeco_aldea || true
	@docker network create neeco_cadena || true
	@docker network create neeco_cuenta || true
	@docker network create neeco_dios || true
	@docker network create neeco_kong || true
	@docker network create neeco_puerta || true
puerta-networks:
	@docker network create --internal neeco_puerta-web || true
	@docker network create --internal neeco_puerta-kong || true
	@docker network create --internal neeco_puerta-dios || true
kong-networks:
	@docker network create --internal neeco_kong-aldea || true
	@docker network create --internal neeco_kong-cadena || true
	@docker network create --internal neeco_kong-cuenta || true
dios-networks:
	@docker network create --internal neeco_dios-aldea || true
	@docker network create --internal neeco_dios-cuenta || true
	@docker network create --internal neeco_dios-kong || true
imagen-networks:
	@docker network create --internal neeco_aldea-imagen || true
	@docker network create --internal neeco_cadena-imagen || true
	@docker network create --internal neeco_cuenta-imagen || true
internal-networks:
	@docker network create --internal neeco_aldea-cuenta || true
	@docker network create --internal neeco_cadena-cuenta || true

import_default-files: volumes
	docker run --rm -i -v neeco_public:/work registry.neec.xyz/neeco/cuenta-application:latest ash -c "cd /app/uploads/ && cp -r --parents images/users/defaults /work/"
	docker run --rm -i -v neeco_public:/work registry.neec.xyz/neeco/aldea-application:latest ash -c "cd /app/uploads/ && cp -r --parents images/events/default.png /work/"

cert:
	docker run -it --rm \
  -p 80:80 -p 443:443 \
  -v /etc/letsencrypt:/etc/letsencrypt \
  quay.io/letsencrypt/letsencrypt:latest certonly \
  --standalone --agree-tos -m nhac.neeco@gmail.com \
  -d neec.ooo -d api.neec.ooo -d admin.neec.ooo -d static.neec.ooo

htpasswd:
	htpasswd -c ./.htpasswd neeco
