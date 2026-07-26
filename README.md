## gists-tips-manager

Japanese README is available here: [README_ja.md](./README_ja.md)

An interactive CLI that lets you easily create small Tips articles—including the reasoning and background behind them—as GitHub Gists.

## What you get from this repository

- A CLI command for creating Tips as GitHub Gists
- An interactive UI for writing a Tip's description and background into a Gist
- A parsing implementation built on the GitHub API, so Tips created as GitHub Gists can be consumed by blogs and other services

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
├── LICENSE
├── README.md
├── README_ja.md
├── assets
│   └── assets.json
├── docs
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

| Command              | Role                                                                    |
| -------------------- | ----------------------------------------------------------------------- |
| setup-manager        | Loads the commands into `.zshrc`. Initial setup.                        |
| tip-new (planned)    | Interactively fill in the frontmatter, then write the body in `$EDITOR` |
| tip-list (planned)   | List Tips along with their status                                       |
| tip-update (planned) | Update a published Gist's content via `gh gist edit`                    |

## Frontmatter

### Format

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

### Frontmatter fields

| Field      | Role                                   | Value                                    |
| ---------- | -------------------------------------- | ---------------------------------------- |
| title      | Title                                  | -                                        |
| summary    | A short description of the Tip         | -                                        |
| tags       | Tags for the Tip                       | Array chosen from `./assets/assets.json` |
| lang       | Language(s) covered in the Tip         | Array chosen from `./assets/assets.json` |
| created_at | Creation date                          | String formatted as `yy-MM-dd`           |
| updated_at | Last updated date                      | String formatted as `yy-MM-dd`           |
| status     | State of the Tip file                  | Either `draft` or `uploaded`             |
| gist_id    | ID assigned when registered as a Gist  | -                                        |
| gist_url   | URL assigned when registered as a Gist | -                                        |
