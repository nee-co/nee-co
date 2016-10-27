# Nee-co

## 概要

* 各BEサブシステム統合リポジトリ
* Kong管理
* Reverse Proxy
* ~~ログ集約~~ まだ

## 使うもの
* **MUST**
    + [Git](http://git-scm.com/)
    + [Docker](https://www.docker.com/products/overview/)
    + [Docker Compose](https://docs.docker.com/compose/install/)

* SHOULD
    + [jq](https://stedolan.github.io/jq/download/) JSON Parser
    + [Postman](https://www.getpostman.com/) REST APIs Client

---

## SubModule

* 各サブシステムをGit SubModuleで管理している
* 初期clone `git clone --recursive git@bitbucket.org:nhac/nee-co.git`
* 更新 `git submodule update`

## 各サブシステムのイメージ取得

* ~~Nee-co共有レジストリから取得~~ まだ
* 手元環境でビルド
    + `make images`

## 構築手順

### 共通ボリューム・ネットワーク作成

```
make volumes

make networks
```

### デフォルトファイルをボリュームに取り込み

```
make import_default-files
```

### コンテナ立ち上げ
```
# DB立ち上げ
make up_db

# (初回のみ) DB Migration
make setup_db

# (初回のみ 開発時のみ) ダミーユーザ追加
mysql -uroot -proot -h127.0.0.1 -P13306 cuenta_prod < dummy.sql

# 各アプリ立ち上げ
make up_app

# リバースプロキシ立ち上げ
make up_proxy
```

### Kong API登録

* ~~Dios上で管理~~ まだ
* 手動登録(API)

```
# Cuentaを登録(ユーザ側)
curl -sS -X POST --url http://localhost:8001/apis/ --data 'name=cuenta' --data 'upstream_url=http://cuenta-application:4000' --data 'request_path=/users' | jq

# Cuentaを登録(認証側)
curl -sS -X POST --url http://localhost:8001/apis/ --data 'name=cuenta-auth' --data 'upstream_url=http://cuenta-application:4000' --data 'request_path=/auth' | jq

# Aldeaを登録
curl -sS -X POST --url http://localhost:8001/apis/ --data 'name=aldea' --data 'upstream_url=http://aldea-application:3000' --data 'request_path=/events' | jq

# Cajaを登録
curl -sS -X POST --url http://localhost:8001/apis/ --data 'name=caja' --data 'upstream_url=http://caja-application:9000' --data 'request_path=/files' | jq

# CORS設定
curl -sS -X POST http://localhost:8001/apis/$(curl -s http://localhost:8001/apis/cuenta | jq -r '.id')/plugins --data "name=cors" | jq
curl -sS -X POST http://localhost:8001/apis/$(curl -s http://localhost:8001/apis/cuenta-auth | jq -r '.id')/plugins --data "name=cors" | jq
curl -sS -X POST http://localhost:8001/apis/$(curl -s http://localhost:8001/apis/aldea | jq -r '.id')/plugins --data "name=cors" | jq
curl -sS -X POST http://localhost:8001/apis/$(curl -s http://localhost:8001/apis/caja | jq -r '.id')/plugins --data "name=cors" | jq

# CuentaにJWT認証を登録(これを登録するとAPI curlに認証が必要になるため注意)
curl -sS -X POST http://localhost:8001/apis/$(curl -s http://localhost:8001/apis/cuenta | jq -r '.id')/plugins --data "name=jwt" --data "config.claims_to_verify=exp" | jq

# AldeaにJWT認証を登録(これを登録するとAPI curlに認証が必要になるため注意)
curl -sS -X POST http://localhost:8001/apis/$(curl -s http://localhost:8001/apis/aldea | jq -r '.id')/plugins --data "name=jwt" --data "config.claims_to_verify=exp" | jq

# CajaにJWT認証を登録(これを登録するとAPI curlに認証が必要になるため注意)
curl -sS -X POST http://localhost:8001/apis/$(curl -s http://localhost:8001/apis/caja | jq -r '.id')/plugins --data "name=jwt" --data "config.claims_to_verify=exp" | jq
```
