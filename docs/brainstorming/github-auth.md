## GitHub上でOAuth Appを作成し、`clientId`を取得する

## userの`token`の扱い

### `createOAuthDeviceAuth`を利用して、`access token`と`refresh token`を取得することができる

- [octokit/auth-oauth-device](https://github.com/octokit/auth-oauth-device.js/#for-oauth-apps)
  - [expired tokenを使用している場合](https://docs.github.com/ja/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps#refreshing-an-access-token-with-a-refresh-token)、refresh tokenも返ってくる

- [戻り値](https://docs.github.com/ja/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps#step-3-app-polls-github-to-check-if-the-user-authorized-the-device)

```txt
access_token=gho_16C7e42F292c6912E7710c838347Ae178B4a
&expires_in=28800
&refresh_token=ghr_1B4a2e77838347a7E420ce178F2E7c6912E169246c34E1ccbF66C46812d16D5B1A9Dc86A1498
&refresh_token_expires_in=15897600
&token_type=bearer
&scope=repo%2Cgist
```

### keytarでOS keychainにwriteする

- keytarの記述に従う

## octokitでgistへアクセスする

### keytarでOS keychainからtokenをreadする

- keytarの記述に従う

### tokenでoctokitクライアントを初期化する

- どうやって期限切れを確認する？
- 期限切れの場合、tokenを更新する
  - 更新したtokenをkeytarでOS keychainにwriteする

### octokitクライアントでGistを扱う

- [GitHub REST API - Gists](https://octokit.github.io/rest.js/v22/#gists)

## Octokitの初期化

- func: アクセストークンを取得する
  - func: keytarでアクセストークンをreadする
  - if: アクセストークンがない
    - func: アクセストークンを発行する
    - func: keytarでアクセストークンをwriteする
    - func: keytarでリフレッシュトークンをwriteする
  - if: アクセストークンの条件にあわない
    - func: アクセストークンを発行する
    - func: keytarでアクセストークンをwriteする
    - func: keytarでリフレッシュトークンをwriteする
  - if: アクセストークンがexpired
    - func: アクセストークンをリフレッシュする
    - func: keytarでアクセストークンをwriteする
    - func: keytarでリフレッシュトークンをwriteする
- func: アクセストークンを使ってOctokitを初期化する
  - if: GitHub APIのリクエストが`401`を返す
    - func: アクセストークンをリフレッシュする
    - func: keytarでアクセストークンをwriteする
    - func: keytarでリフレッシュトークンをwriteする

## configファイル読み込み

config.system.json

```json
{
  "autoSlug": true,
  "frontmatterDefault": true,
  "categories": [""]
}
```

- func:isAutoSlug
- func: isFrontmatterDefault
- funt: getCategories

## gist CRUD #18

- func: gistControler
  - func: createGist
  - func: getGist
  - func: getGistList
  - func: updateGist
  - func: deleteGist
  - func: syncGist

## ローカル作業ディレクトリ操作 #19

- func: directoryControler

## slug生成 #20

- func: createSlug

## カテゴリ追記

- addCategory
-

Gistっていうentity,classがある？

### func: アクセストークンを発行する

- func: config.jsonからclientIdを取得
  - if: clientIdがない
  - if: config.jsonがない
  - if: clientIdの条件に合わない
- func: WIP

### func: keytarで{arg}をread/writeする

> e.g.
> keytarでアクセストークンをreadする
> keytarでリフレッシュトークンをreadする
> keytarでアクセストークンをwriteする
> keytarでリフレッシュトークンをwriteする

### func: アクセストークンをリフレッシュする

- if: リフレッシュトークンが存在しない
  - func: アクセストークンの発行
