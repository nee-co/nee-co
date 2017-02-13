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

## サブシステム

| システム名 |        概要      |          リポジトリURL            |
|:----------:|:----------------:|:---------------------------------:|
|   Aldea    |  イベント管理API | https://bitbucket.org/nhac/aldea  |
|    Caja    |  ファイル管理API | https://bitbucket.org/nhac/caja   |
|   Cadena   |  グループ管理API | https://bitbucket.org/nhac/cadena |
|   Cuenta   |   ユーザ管理API  | https://bitbucket.org/nhac/cuenta |
|    Dios    | 管理者用システム | https://bitbucket.org/nhac/dios   |
|    Kong    |    API Gateway   | https://bitbucket.org/nhac/kong   |
|   Puerta   |   Reverse Proxy  | https://bitbucket.org/nhac/puerta |

## 各サブシステムのイメージ取得

* Nee-co共有レジストリから取得

例)

```
docker pull registry.neec.xyz/neeco/aldea-application:latest
```

## 構築手順

### 共通ボリューム・ネットワーク作成

```
make volumes

make networks
```

### 環境変数設定(必要に応じて適宜変更)

```
cp .env{.example,}
```

### 証明書作成

```
make cert
```

### コンテナ立ち上げ
```
# DB立ち上げ
make db

# DB Migration
make migrate

# (初回のみ) シード投入
make seed

# 各アプリ立ち上げ
make app

# リバースプロキシ立ち上げ
make proxy
```

### Kong API登録

* Dios上で頑張って

### ユーザ登録

* Dios上で頑張って
