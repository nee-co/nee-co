# 事前準備
# - Dockerが稼働する環境を用意する(Docker for Mac 1.12.0で動作確認済み)
# - 各サブシステムでイメージを作成しておく( `aldea-application`  )
# - jq をインストールしておく (必須ではないが、JSONをそのまま見るのは辛いので推奨)

# 各DBを立ち上げる
docker-compose up -d kong-database cuenta-database aldea-database

# DBが立ち上がりきっていないとアプリが起動できないため少し待つ

# Kong起動
docker-compose up -d kong-application

# Kongに登録されているAPI一覧を表示 => 空を確認
curl -sS http://localhost:8001/apis | jq

# Cuenta ============================================================

# CuentaDB作成 初回のみ実行する
docker-compose run cuenta-application mix ecto.setup

# ダミーデータ挿入(環境によって入れ方異なるので各自で頑張って! mysql-client入っているなら下のコメンドでok) warning出るけど無視
mysql -uroot -proot -h127.0.0.1 -P13306 cuenta_prod < dummy.sql

# Cuenta起動
docker-compose up -d cuenta-application

# 試しにユーザAPIを読ぶ => ポートを開けていないため呼べないことを確認
curl http://localhost:4000/users/list?user_ids=1

# KongにCuentaを登録
curl -sS -X POST --url http://localhost:8001/apis/ --data 'name=cuenta' --data 'upstream_url=http://cuenta-application:4000' --data 'request_path=/users' | jq

# KongにCuentaが登録されていることを確認
curl -sS http://localhost:8001/apis | jq

# Kong経由でユーザAPIを呼ぶ
curl -sS http://localhost:8000/users/list?user_ids=1 | jq

# Aldea ============================================================

# AldeaDB作成 初回のみ実行する
docker-compose run aldea-application bundle exec rails db:setup

# Aldea起動
docker-compose up -d aldea-application

# 試しにイベントAPIを読ぶ => ポートを開けていないため呼べないことを確認
curl http://localhost:3000/events

# KongにAldeaを登録
curl -sS -X POST --url http://localhost:8001/apis/ --data 'name=aldea' --data 'upstream_url=http://aldea-application:3000' --data 'request_path=/events' | jq

# KongにAldeaが登録されていることを確認
curl -sS http://localhost:8001/apis | jq

# Kong経由でイベントAPIを呼ぶ
curl -sS http://localhost:8000/events | jq

# JWT Plugin ============================================================

# CuentaにJWT認証を登録(これを登録するとAPI curlに認証が必要になるため注意)
curl -sS -X POST http://localhost:8001/apis/$(curl -s http://localhost:8001/apis/cuenta | jq -r '.id')/plugins --data "name=jwt" --data "config.claims_to_verify=exp" | jq

# CuentaにJWT認証Pluginが登録されていることを確認
curl -sS http://localhost:8001/apis/cuenta/plugins | jq

## ここから下は本来Cuentaが処理する(まだ未実装)

# ID=1のユーザをConsumer登録
curl -sS -X POST http://localhost:8001/consumers --data "username=g002b8136" --data "custom_id=1" | jq

# ID=1のユーザがConsumerに登録されていることを確認
curl -sS http://localhost:8001/consumers/g002b8136 | jq

curl -X POST http://localhost:8001/consumers/$(curl -sS http://localhost:8001/consumers/g002b8136 | jq -r .id)/jwt --data '' | jq
