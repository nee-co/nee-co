.PHONY: proxy db app seed migrate volumes networks cert htpasswd

proxy:
	docker-compose up -d puerta-application

db:
	docker-compose up -d aldea-database cadena-database caja-database caja-redis cuenta-database dios-database kong-database olvido-database

app:
	docker-compose up -d aldea-application cadena-application caja-application cuenta-application dios-application imagen-application kong-application olvido-application web-application

seed: seed-cuenta seed-dios;
seed-cuenta:
	docker-compose run --rm cuenta-application mix ecto.seed
seed-dios:
	docker-compose run --rm dios-application bundle exec rails db:seed

migrate: migrate-aldea migrate-cadena migrate-cuenta migrate-dios;
migrate-aldea:
	docker-compose run --rm aldea-application bundle exec rails db:migrate
migrate-cadena:
	docker-compose run --rm cadena-application bundle exec rails neo4j:migrate
migrate-cuenta:
	docker-compose run --rm cuenta-application mix ecto.migrate
migrate-dios:
	docker-compose run --rm dios-application bundle exec rails db:migrate

volumes:
	@docker volume create --name neeco_aldea || true
	@docker volume create --name neeco_cadena || true
	@docker volume create --name neeco_caja || true
	@docker volume create --name neeco_cuenta || true
	@docker volume create --name neeco_dios || true
	@docker volume create --name neeco_kong || true
	@docker volume create --name neeco_olvido || true
	@docker volume create --name neeco_images || true

network:
	@docker network create neeco_develop || true

cert:
	docker run -it --rm \
  -p 80:80 -p 443:443 \
  -v /etc/letsencrypt:/etc/letsencrypt \
  quay.io/letsencrypt/letsencrypt:latest certonly \
  --standalone --agree-tos -m nhac.neeco@gmail.com \
  -d neec.ooo -d api.neec.ooo -d admin.neec.ooo -d static.neec.ooo
