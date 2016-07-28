# 各DBを立ち上げる
docker-compose up -d kong-database cuenta-database

# DBが立ち上がりきっていないとアプリが起動できないため少し待つ

# CuentaDB作成 初回のみ実行する
docker-compose run cuenta-application mix ecto.setup

# ダミーデータ挿入(環境によって入れ方異なるので各自で頑張って! mysql-client入っているなら下のコメンドでok) warning出るけど無視
mysql -uroot -proot -h127.0.0.1 -P13306 cuenta_prod < dummy.sql

# Cuenta起動
docker-compose up -d cuenta-application

# 試しにユーザ検索APIを読ぶ => ポートを開けていないため呼べないことを確認
curl http://localhost:4000/users/list?user_ids=1

# Kong起動
docker-compose up -d kong-application

# Kongに登録されているAPI一覧を表示 => 空を確認
curl -sS http://localhost:8001/apis | jq

# KongにCuentaを登録
curl -sS -X POST --url http://localhost:8001/apis/ --data 'name=cuenta' --data 'upstream_url=http://cuenta-application:4000' --data 'request_path=/users' | jq

# KongにCuentaが登録されていることを確認
curl -sS http://localhost:8001/apis | jq

# Kong経由でユーザAPIを呼ぶ
curl -sS http://localhost:8000/users/list?user_ids=1 | jq
