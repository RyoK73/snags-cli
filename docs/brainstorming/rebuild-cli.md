## 全体構想

通常、tips,cheatsheet,howtoなどはブログに書かれることが多い。
しかし、ブログのような読み物ベースのドキュメントは、これらの*課題解決*系の保存形式としては閲覧性や検索性、保管性も悪い。あとから or 誰かがネット上から探す場合に探しにくい。
また、AIの登場によりStackOverflowに代表されるネット質問掲示板による一次情報の蓄積が減少していることにより、将来的なユーザー,AIの学習が悪化することが考えられる。

上記を踏まえ、ブログとは独立した、tips,cheatsheet,howtoなどを記録する媒体が必要になる

- ブログのような文章を書く媒体ではない
- 自分で用意しなくてよいプラットフォームとして提供される
- terminalネイティブなCLIが提供される
- Web上でも編集できる
- MDとしてエクスポート可能であるため、すべてがユーザー自身の資産として積み上がる
- webアプリ内で自分のドメインを利用してテックログサイトとして公開可能
  - SEO対策されておりtipsそれ自体を検索エンジンから見つけることができる
- 自身の個人ブログでレンダリングするためのAPIを提供する
- Githubアカウント,アプリユーザー双方のログイン手段を提供する(gist機能を用いるためgithubアカウントログインは必要...悩み中)
- 現状、画像取り込み機能はなし(コードスニペット及び解説文や紹介文のみを想定)

### 現状整理

- zshで記述した`gh gist`のラッパーcli
- bashでの利用なし
- 正直使いにくい

### 今後の展望

- CLIの拡張:
  - node.jsベースのcli
  - metadataとして持っておくべき内容をフロントマター用のMDを作成して保持
  - ユーザーのエディターで開く
- Webフロントエンドアプリの提供:
  - Supabase DBへMDを保管
  - ビューワーとしての機能のみを持つ
  - エディターはgithub上で行う:
    - エディター機能の実装コストが高い
    - github gistと同期する必要があるため、編集機能を提供してしまうとアプリのDBとgh gistの間で差異が発生してしまい同期の通信量が増加する
    - キーボードネイティブなUIを提供
    - 無料
- ブログへの埋め込みAPIの提供
  - フロントマターとコードブロック込みのHTMLを返す
  - tips一覧,個別tipsの双方を返す

### 名称

- git-tips-manager(gtm)
- 迷い中
- Code,snipet,tips,cheatsheet,howto
- management,view,save,view
- system
- useful,helpful,friendly

Tips System for quicky writing,reading and keep

=> SNAGS(Snag the Note, Archive, Gist and Snippet): Snippet,Note,Archive,Gistをさっと手に入れる

## SNAGS CLI

### 技術スタック

- Node.js
- GitHub CLI

### CLI Details

- ログ: consola
-

## SNAGS Web App

### 技術スタック

- Next.js: 表示ページのSSR/ISR
- Supabase: GitHub OAuthのセッション管理
- CloudFlare: Domain管理

### Typical Flow

#### Create

1. Create Tips by SNAGS CLI
2. push to gh gist & Push to SNAGS Web DB
3. _on GitHub_ View and Edit / _on Web App_ View

#### Edit

- on SNAGS App

1. Click Tips Edit Button(beta)
2. Jump to GitHub Gist
3. Edit
4. Turn to SNAGS App

- on SNAGS CLI

1. View Tips List(fetch from GitHub Gist)
2. Select
3. Edit in your Editor
4. End: Push the tips to GitHub Gist and SNAGS DB

## SNAGS Web API

- Next.js App Router: Provide the API

## MVP Scope

### 1st

- Provide Pure CLI(without SNAGS Web App)
- feature:
  - Useful CLI by CLI Alias(not `pnpm snags ...`)
  - Push to GitHub(not SNAGS DB)
  - Command:
    - Create
    - Edit
    - List
    - Delete
    - Sync
    - more

### 2st

- Provide Web App and link CLI
- Provide tips list viewer like SNS(infinite scrolling) and List View(list on left, details on right)

### 3st

- Provide CodeBlock API Endpoint(beta)
