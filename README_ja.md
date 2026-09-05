# SNAGS CLI

English README is available here: [README.md](./README.md)

**Snags the Note, Archive, Gist, and Snippet.**

作成理由・背景も含めた小さなTips記事をGithub Gistとして手軽に作成できる対話式CLI

## このリポジトリで得られるもの

- TipsとしてGitHub Gistを作成するためのCLIコマンド
- Tipsの説明・背景などをGistに書き込むための対話式UI
- ローカルの`tips/`配下は`.gitignore`で除外されており、リポジトリにはコミットされない（Gist側が正となる）

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
├── .github
├── .gitignore
├── CLAUDE.md
├── LICENSE
├── README.md
├── README_ja.md
├── assets
│   └── assets.json
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

| コマンド      | 役割                                                                      |
| ------------- | ------------------------------------------------------------------------- |
| setup-manager | コマンドを`.zshrc`に読み込む。初回セットアップ                            |
| tip-new       | メタデータを対話入力 -> `$EDITOR`で本文執筆 -> 確認後にGistへアップロード |
| tip-list      | 作成済みのGist Tips一覧を表示                                             |
| tip-edit      | Tipsを選択して`$EDITOR`で編集 -> 確認後にGistへ再アップロード             |

## 使用方法

### tip-new — 新しいTipsを作成する

1. `tip-new` を実行すると「Let's Create Tips !」のバナーが表示される
2. `Enter a filename` -> ファイル名を入力
3. `Enter a title` -> タイトルを入力
4. `Choose a category` -> `./assets/assets.json`の`category`一覧から複数選択（Tab等で複数選択可）
5. `Choose a language` -> `./assets/assets.json`の`language`一覧から1つ選択（本文ファイルの拡張子決定に使うのみで、`meta.yaml`には保存されない）
6. `tips/{YYYY-MM-DD}-{ファイル名}/`ディレクトリが作成され、本文ファイルと`{ファイル名}.meta.yaml`が生成される
7. `Open with ${EDITOR}?`
   - `No` -> `Created at {tip_dir}`と表示されて終了（ローカルに作成されるのみで、Gistへは未アップロード）
   - `Yes` -> `$EDITOR`が開き本文を編集。保存して閉じると`Upload to gist?`と確認され、
     - `Yes` -> `gh gist create`で新規Gistが作成され、発行された`gist_id`が`meta.yaml`に書き戻される。`Gist created: {url}`と表示される
     - `No` -> アップロードせず終了

### tip-list — 作成済みのTips一覧を見る

1. `tip-list` を実行すると「Your Tips !」のバナーが表示される
2. `gh gist list --filter '[Tips]'`の結果が、ID / Description / Files / Visibility / UpdatedAtの列を持つ表として表示される

### tip-edit — 既存のTipsを編集する

1. `tip-edit` を実行すると「Edit Tips !」のバナーが表示される
2. `tip-list`と同じ一覧表が表示されるので、編集したいTipsを1つ選択する
3. ローカルに該当するTipsディレクトリがあればそれを使用。無ければ（他PCで作成されたTipsなど）`gh gist clone`で取得し、`tips/`配下に配置される
4. 以降は`tip-new`の手順6-7と同様の編集フローに入る。既存Gistへの更新となるため、アップロード時は`gh gist edit`が使われ、`Gist ({id}) updated`と表示される

### ユースケース別のコマンド選択

| やりたいこと                                                         | コマンド      |
| -------------------------------------------------------------------- | ------------- |
| 初めてこのツールを使う（`.zshrc`にコマンドを読み込む）               | setup-manager |
| 新しいTipsを書いてGistとして公開したい                               | tip-new       |
| 自分が作成済みのTips一覧を見たい                                     | tip-list      |
| 既存のTips（他PCで作成したものを含む）を修正して再アップロードしたい | tip-edit      |

## メタデータ

### 記述方法

各Tipsは`tips/{作成日}-{ファイル名}/`配下に本文ファイルとは別の`{ファイル名}.meta.yaml`という独立したYAMLファイルとして生成される。Markdown内のfrontmatterではなく、`yq`で読み書きする単独のYAMLファイルである。

```yaml
title: ""
category: []
created_at: ""
gist_id: ""
```

### フィールド

| フィールド | 役割                        | 値                                   |
| ---------- | --------------------------- | ------------------------------------ |
| title      | タイトル                    | -                                    |
| category   | tipsのカテゴリ              | `./assets/assets.json`から選んだ配列 |
| created_at | 作成日                      | `yyyy-MM-dd`で表記される文字列       |
| gist_id    | gistsとして登録したときのid | -                                    |
