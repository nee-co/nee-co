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
* 更新 `git submodule update --remote`

### List

| システム名 |        概要      |          リポジトリURL            |
|:----------:|:----------------:|:---------------------------------:|
|   Aldea    |  イベント管理API | https://bitbucket.org/nhac/aldea  |
|    Caja    |  ファイル管理API | https://bitbucket.org/nhac/caja   |
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

### デフォルトファイルをボリュームに取り込み

```
make import_default-files
```

### 証明書作成

```
make cert
```

### htpasswd作成

```
make htpasswd
```

### コンテナ立ち上げ
```
# DB立ち上げ
make db

# DB Migration
make migrate

# (初回のみ) シード投入
make seed

# (初回のみ 開発時のみ) ダミーユーザ追加
mysql -uroot -proot -h127.0.0.1 -P13306 cuenta_prod < dummy.sql

# 各アプリ立ち上げ
make app

# リバースプロキシ立ち上げ
make proxy
```

### Kong API登録

* Dios上で管理
