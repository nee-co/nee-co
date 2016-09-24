# 事前準備
# - Dockerが稼働する環境を用意する(Docker for Mac 1.12.0で動作確認済み)
# - 各サブシステムでイメージを作成しておく( `aldea-application`  )
# - jq をインストールしておく (必須ではないが、JSONをそのまま見るのは辛いので推奨)

# 各DBを立ち上げる
docker-compose up -d kong-database cuenta-database aldea-database dios-database

# DBが立ち上がりきっていないとアプリが起動できないため少し待つ

# Kong起動
docker-compose up -d kong-application

# Kongに登録されているAPI一覧を表示 => 空を確認
curl -sS http://localhost:8001/apis | jq

# Cuenta ============================================================

# CuentaDB作成 初回のみ実行する
docker-compose run --rm cuenta-application mix ecto.setup

# ダミーデータ挿入(環境によって入れ方異なるので各自で頑張って! mysql-client入っているなら下のコメンドでok) warning出るけど無視
mysql -uroot -proot -h127.0.0.1 -P13306 cuenta_prod < dummy.sql

# Cuenta起動
docker-compose up -d cuenta-application

# 試しにユーザAPIを呼ぶ => ポートを開けていないため呼べないことを確認
curl http://localhost:4000/users/list?user_ids=1

# KongにCuentaを登録(ユーザ側)
curl -sS -X POST --url http://localhost:8001/apis/ --data 'name=cuenta' --data 'upstream_url=http://cuenta-application:4000' --data 'request_path=/users' | jq

# KongにCuentaを登録(認証側)
curl -sS -X POST --url http://localhost:8001/apis/ --data 'name=cuenta-auth' --data 'upstream_url=http://cuenta-application:4000' --data 'request_path=/auth' | jq

# KongにCuentaが登録されていることを確認
curl -sS http://localhost:8001/apis | jq

# Kong経由でユーザAPIを呼ぶ
curl -sS http://localhost:8000/users/search?str=g013 | jq

# Aldea ============================================================

# AldeaDB作成 初回のみ実行する
docker-compose run --rm aldea-application bundle exec rails db:setup

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

# AldeaにJWT認証を登録(これを登録するとAPI curlに認証が必要になるため注意)
curl -sS -X POST http://localhost:8001/apis/$(curl -s http://localhost:8001/apis/aldea | jq -r '.id')/plugins --data "name=jwt" --data "config.claims_to_verify=exp" | jq

# Cuenta/AldeaにJWT認証Pluginが登録されていることを確認
curl -sS http://localhost:8001/apis/cuenta/plugins | jq
curl -sS http://localhost:8001/apis/aldea/plugins | jq

# tokenを含めずにCuenta/Aldeaにアクセスする(認証エラーとなる)
curl -sS http://localhost:8000/users/search?str=g013 | jq
curl -sS http://localhost:8000/events | jq

# Cuentaにログインする(同時にCuenta => Kongへのconsumer登録APIが送信される)
curl -sS -X POST http://localhost:8000/auth/login --data 'number=g002b8136' --data 'password=g002b8136password' | jq -r .token | tee token

# ID=1のユーザがConsumerに登録されていることを確認
curl -sS http://localhost:8001/consumers/g002b8136 | jq

# tokenを含めてCuentaにアクセスする
cat token | xargs -I {} curl -sS -H 'Authorization: Bearer {}' http://localhost:8000/users/search?str=G | jq

# tokenを含めてAldeaにアクセスする
cat token | xargs -I {} curl -sS -H 'Authorization: Bearer {}' http://localhost:8000/events | jq

# ログイン中のユーザ取得
cat token | xargs -I {} curl -sS -H 'Authorization: Bearer {}' http://localhost:8000/users | jq

# ログイン中のユーザ画像更新
cat token | xargs -I {} curl -sS -X POST -H 'Authorization: Bearer {}' http://localhost:8000/users/image -F image=@kong.png | jq

# Dios ==============================================================

# DiosDB作成 初回のみ実行する
docker-compose run --rm dios-application bundle exec rails db:setup

# Dios起動
docker-compose up -d dios-application

# Diosログイン
open http://localhost:3000/admin
Email/Password: admin@example.com/password
