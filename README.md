## gists-tips-manager

Japanese README is available here: [README_ja.md](./README_ja.md)

An interactive CLI that lets you easily create small Tips articles—including the reasoning and background behind them—as GitHub Gists.

## What you get from this repository

- A CLI command for creating Tips as GitHub Gists
- An interactive UI for writing a Tip's description and background into a Gist
- Local files under `tips/` are excluded via `.gitignore` and never committed to the repository—the Gist is the source of truth

## Installation

1. `sudo pacman -S gum github-cli yq jq`
2. `git clone https://github.com/RyoK73/gists-tips-manager.git`
3. `cd gists-tips-manager`
4. `./scripts/setup-manager.zsh`
5. `source $HOME/.zshrc`

## Requirements

### OS

- Arch Linux

### Shell

- zsh

## Structure

```bash
├── .github
├── .gitignore
├── CLAUDE.md
├── LICENSE
├── README.md
├── README_ja.md
├── assets
│   └── assets.json
├── scripts
│   ├── gists-tips-manager.zsh
│   └── setup-manager.zsh
└── tips
```

## Dependencies

- [gum](https://github.com/charmbracelet/gum.git)
- [GitHub CLI](https://github.com/cli/cli.git)
- [jq](https://github.com/jqlang/jq)
- [yq (kislyuk/yq)](https://github.com/kislyuk/yq) — a jq-based YAML processor, used to read/write `meta.yaml`

## Commands

Implemented in `./scripts/gists-tips-manager.zsh`

| Command       | Role                                                                                 |
| ------------- | ------------------------------------------------------------------------------------- |
| setup-manager | Loads the commands into `.zshrc`. Initial setup.                                      |
| tip-new       | Interactively fill in the metadata, write the body in `$EDITOR`, then upload to a Gist after confirmation |
| tip-list      | List the Gist Tips that have already been created                                     |
| tip-edit      | Select a Tip, edit it in `$EDITOR`, then re-upload to the Gist after confirmation      |

## Usage

### tip-new — create a new Tip

1. Run `tip-new`. A "Let's Create Tips !" banner is shown.
2. `ファイル名を入力してください` (Enter a file name) -> enter a file name
3. `タイトルを入力してください` (Enter a title) -> enter a title
4. `タグを選んでください` (Choose tags) -> select one or more categories from `./assets/assets.json` (multi-select)
5. `言語を選んでください` (Choose a language) -> select a single language from `./assets/assets.json` (used only to determine the body file's extension; it is not stored in `meta.yaml`)
6. A `tips/{YYYY-MM-DD}-{filename}/` directory is created, containing the body file and `{filename}.meta.yaml`
7. `${EDITOR}で開きますか？` (Open in $EDITOR?)
   - `No` -> prints `{tip_dir} に作成しました` and exits (the Tip is created locally only, not yet uploaded to a Gist)
   - `Yes` -> `$EDITOR` opens for the body. After saving and closing, `gistにアップロードしますか？` (Upload to a Gist?) is asked.
     - `Yes` -> `gh gist create` creates a new Gist, and the resulting `gist_id` is written back into `meta.yaml`. Prints `gistを作成しました: {url}`.
     - `No` -> exits without uploading

### tip-list — browse existing Tips

1. Run `tip-list`. A "Your Tips !" banner is shown.
2. The output of `gh gist list --filter '[Tips]'` is displayed as a table with ID / Description / Files / Visibility / UpdatedAt columns.

### tip-edit — edit an existing Tip

1. Run `tip-edit`. An "Edit Tips !" banner is shown.
2. The same table as `tip-list` is shown; select the Tip to edit.
3. If a matching Tip directory exists locally, it is reused. Otherwise (e.g. a Tip created on another machine) it is fetched with `gh gist clone` and placed under `tips/`.
4. From here the flow matches steps 6-7 of `tip-new`. Since the Gist already exists, uploading uses `gh gist edit` and prints `gist({id})を更新しました` (Gist updated).

### Which command should I use?

| I want to...                                                          | Command       |
| ------------------------------------------------------------------- | ------------- |
| Use this tool for the first time (load the commands into `.zshrc`)  | setup-manager |
| Write a new Tip and publish it as a Gist                            | tip-new       |
| Browse the Tips I've already created                                | tip-list      |
| Edit an existing Tip (including ones created on another machine) and re-upload it | tip-edit      |

## Metadata

### Format

Each Tip is generated under `tips/{created_at}-{filename}/`, alongside the body file, as a separate `{filename}.meta.yaml` file. It is not Markdown frontmatter — it's a standalone YAML file read and written with `yq`.

```yaml
title: ""
category: []
created_at: ""
gist_id: ""
```

### Fields

| Field      | Role                                   | Value                                    |
| ---------- | --------------------------------------- | ----------------------------------------- |
| title      | Title                                   | -                                         |
| category   | Category for the Tip                    | Array chosen from `./assets/assets.json`  |
| created_at | Creation date                           | String formatted as `yyyy-MM-dd`          |
| gist_id    | ID assigned when registered as a Gist   | -                                         |
