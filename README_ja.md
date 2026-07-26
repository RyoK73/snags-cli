## gists-tips-manager

English README is available here: [README.md](./README.md)

作成理由・背景も含めた小さなTips記事をGithub Gistとして手軽に作成できる対話式CLI

## このリポジトリで得られるもの

- TipsとしてGitHub Gistを作成するためのCLIコマンド
- Tipsの説明・背景などをGistに書き込むための対話式UI
- GitHub Gistに作成されたTipsをブログ・サービスなどで利用可能にするGitHub APIを通したパース実装

## インストール方法

1. `sudo pacman -S gum github-cli yq jq`
2. `git clone https://github.com/RyoK73/gists-tips-manager.git`
3. `cd gists-tips-manager`
4. `./scripts/setup-manager.zsh`
5. `source $HOME/.zshrc`

## 動作環境

### OS

- Arch Linux

### シェル

- zsh

## 構成

```bash
├── LICENSE
├── README.md
├── README_ja.md
├── assets
│   └── assets.json
├── docs
├── scripts
│   ├── gists-tips-manager.zsh
│   └── setup-manager.zsh
└── tips
```

## 依存ライブラリ

- [gum](https://github.com/charmbracelet/gum.git)
- [GitHub CLI](https://github.com/cli/cli.git)
- [jq](https://github.com/jqlang/jq)
- [yq (kislyuk/yq)](https://github.com/kislyuk/yq) — jqラッパー形式のYAMLパーサー。meta.yamlの読み書きに使用

## コマンド

`./scripts/gists-tips-manager.zsh`に実装

| コマンド             | 役割                                           |
| -------------------- | ---------------------------------------------- |
| setup-manager        | コマンドを`.zshrc`に読み込む。初回セットアップ |
| tip-new(実装予定)    | フロントマターを対話入力 -> $EDITORで本文執筆  |
| tip-list(実装予定)   | tips一覧をstatusつきで表示                     |
| tip-update(実装予定) | 公開済みgistの内容を`gh gist edit`で更新       |

## フロントマター

### 記述方法

```md
---
title:""
summary:""
tags:[]
lang:""
created_at:""
updated_at:""
status:""
gist_id:""
gist_url:""
---
```

### フロントマターの役割

| フロントマター | 役割                         | 値                                   |
| -------------- | ---------------------------- | ------------------------------------ |
| title          | タイトル                     | -                                    |
| summary        | tipの簡単な説明文            | -                                    |
| tags           | tipsのタグ                   | `./assets/assets.json`から選んだ配列 |
| lang           | tips内で紹介する言語         | `./assets/assets.json`から選んだ配列 |
| created_at     | 作成日                       | `yy-MM-dd`で表記される文字列         |
| updated_at     | 更新日                       | `yy-MM-dd`で表記される文字列         |
| status         | tipファイルの状態            | `draft`,`uploaded`のどちらか         |
| gist_id        | gistsとして登録したときのid  | -                                    |
| gist_url       | gistsとして登録したときのURL | -                                    |
