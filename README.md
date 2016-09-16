# Nee-co

## 概要

* 各BEサブシステム統合リポジトリ
* Kong管理
* ログ集約

## 使うもの
* **MUST**
    + [Git](http://git-scm.com/)
    + [Docker](https://www.docker.com/products/overview/)
    + [Docker Compose](https://docs.docker.com/compose/install/)

* SHOULD
    + [jq](https://stedolan.github.io/jq/download/) JSON Parser
    + [Postman](https://www.getpostman.com/) REST APIs Client

---

## 各サブシステムのイメージ取得

* ~~Nee-co共有レジストリから取得~~ まだ
* 手元環境でビルド
`make build`

### [Cuenta - ユーザ管理API](https://bitbucket.org/nhac/cuenta)
### [Aldea - イベント管理API](https://bitbucket.org/nhac/aldea)
### ~~[Caja - ファイル管理API](https://bitbucket.org/nhac/caja)~~ まだ
### [Dios - 管理者用システム](https://bitbucket.org/nhac/dios)
### [Kong - API Gateway](https://bitbucket.org/nhac/nee-co) 本リポジトリ `cd kong`

## 構築手順

### コンテナ立ち上げ
```
# DB立ち上げ
make up_db

# (初回のみ) DB Migration
make setup_db

# (初回のみ) ユーザデフォルト画像import
make import_default_image

# (初回のみ 開発時のみ) ダミーユーザ追加
mysql -uroot -proot -h127.0.0.1 -P13306 cuenta_prod < dummy.sql

# 各アプリ立ち上げ
make up_app
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

# CuentaにJWT認証を登録(これを登録するとAPI curlに認証が必要になるため注意)
curl -sS -X POST http://localhost:8001/apis/$(curl -s http://localhost:8001/apis/cuenta | jq -r '.id')/plugins --data "name=jwt" --data "config.claims_to_verify=exp" | jq

# AldeaにJWT認証を登録(これを登録するとAPI curlに認証が必要になるため注意)
curl -sS -X POST http://localhost:8001/apis/$(curl -s http://localhost:8001/apis/aldea | jq -r '.id')/plugins --data "name=jwt" --data "config.claims_to_verify=exp" | jq
```
