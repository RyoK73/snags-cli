# ディレクトリ構成規約 - Vertical Codebase -

## ディレクトリ・ファイルの配置ルール

### What

- **技術的な種類(component/hooks/utils)**ではなく、**「何をするか(ドメイン・機能)」**を基準にフォルダを分割する
- 特定のフレームワーク(Next.js/Express/Nest.js等)に依存しない、TypeScriptプロジェクト全般に適用できる構成方針

### Why

- 技術的な関心(component/hook/util/lib)ではなく、意味のあるまとまり(login,widgets...etc)を優先する

| structure  | features                                             | Pros                                                  | Cons                               |
| ---------- | ---------------------------------------------------- | ----------------------------------------------------- | ---------------------------------- |
| horizontal | `src/components,utils,hooks`など*技術種別ごと*で分割 | 一見わかりやすい                                      | コード量増加で参照が増える         |
| vertical   | *なにをするか*で分割                                 | 変更時の参照箇所が1箇所に収まり、認知負荷を下げられる | 分類を見極めるのが難しい場合がある |

## エントリーポイント層は薄く保つ

- ルーティングやAPIエンドポイント定義など、フレームワークが要求する「エントリーポイント」は薄い入り口として扱う
- 具体例: Next.jsの`app/page.tsx`、Expressの`routes/`、Nest.jsの`controller`、CLIの`bin/`など
- エントリーポイント自体にロジックやUIの実装を直接書かず、対応する`src/{vertical名}/`から実装をimportしてつなぐだけにする
- ロジックを混在させるとエントリーポイントの定義と機能実装が同居し、肥大化・可読性低下につながる

### Example (Next.jsの場合)

```bash
src/
├── app/                    # Next.js App Router専用。ルーティングの薄い入り口のみ
│   └── login/
│       └── page.tsx
├── login/                  # 機能単位のvertical。ログインに関するもの全部
│   ├── login-form.tsx
│   ├── login-form.test.tsx
│   ├── use-login.ts
│   ├── login-action.ts
│   ├── login-schema.ts
│   └── index.ts            # 外部公開インターフェース
├── design-system/          # ドメインに属さない汎用UI部品
│   ├── ui/                 # shadcn/uiが生成した"素"のプリミティブ
│   │   ├── button.tsx
│   │   └── dialog.tsx
│   └── primary-button.tsx  # ui/ をラップした自社独自コンポーネント
├── utils/                    # ドメインに属さない汎用関数
└── widgets/                # 複数ページ・機能から使われる独立verticalの例
```

> 上記はNext.jsを例にした場合の構成です。フレームワークが変われば`app/`の部分は`routes/`や`controllers/`などに置き換わりますが、「エントリーポイントは薄く、実装は`src/{vertical名}/`に置く」という考え方自体は変わりません。

## 機能ごとに`src/{vertical名}/`を作り、関連コードをすべて集約する

対象は「見た目を持つコンポーネント」に限らず、hook / util / type / schema / API呼び出し処理 / バッチ処理など種類を問わない。
**「そのvertical(機能)が変更されたら一緒に変更されるか」**を基準に置き場所を判断する。

### Example

ログイン機能なら `src/login/` に、UI(あれば)・バリデーション・API呼び出し・関連する型を全てまとめる。

```bash
src/
├── login/                  # 機能単位のvertical。ログインに関するもの全部
│   ├── login-form.tsx      # UIがない/対象外のプロジェクトでは不要
│   ├── login-form.test.tsx
│   ├── use-login.ts
│   ├── login-action.ts
│   ├── login-schema.ts
│   └── index.ts            # 外部公開インターフェース
```

## 汎用UI部品(または汎用モジュール)は`src/design-system/`へ

- 特定の機能・ドメインに依存しない、再利用前提のUI部品(Button, Input, Dialog等)が対象
- UIを持たないプロジェクト(CLIツール・バックエンドAPI等)の場合は、このフォルダ自体が不要になることもある
- 素のUIライブラリ部品をラップして独自スタイルを当てる場合は `design-system/` 直下に分けて置く

> Ex
> `design-system/ui/button.tsx` ← 素の部品
> `design-system/primary-button.tsx` ← ラップ後

### UIライブラリ生成コードへの対応(該当プロジェクトのみ)

- shadcn/uiなど、CLIでコンポーネントを生成するライブラリを使う場合は、生成先を `src/design-system/ui/` に固定する
- 例えばshadcn/uiであれば `components.json` の `aliases` を変更し、以降の `npx shadcn add` でも自動的に正しい場所に生成されるようにする

```json
// components.json
"aliases": {
  "components": "@/src/design-system",
  "ui": "@/src/design-system",
  "lib": "@/src/design-system/lib",
  "utils": "@/src/design-system/lib/utils",
  "hooks": "@/src/design-system/hooks"
}
```

## 複数のvertical(機能)から使われるコードは、それ自体を独立したverticalにする

- 特定の機能に属さないが、汎用UI部品(または汎用モジュール)とも言えないもの(例: 複数箇所で使う`PageFilters`のような複合UI、複数機能から呼ばれる`NotificationService`のような処理)が対象
- 安易に「共通」フォルダへ逃さず、`src/<新しいvertical名>/` として切り出す

## 各verticalの公開範囲は `index.ts` で明示する

- vertical内部でのみ使うファイル(hookやactionの詳細実装等)は外部からdeep importさせない
- 他のverticalから使わせたいものだけを `index.ts` からexportする

```ts
// src/login/index.ts
export { LoginForm } from "./login-form";
// use-login.ts, login-action.ts は非公開(vertical内部専用)
```

> 検討中: ESLintルール(例: `eslint-plugin-boundaries`)などで、
> `index.ts` を経由しないdeep importを機械的に禁止する

## 判断フローチャート(コードをどこに置くか迷った時)

1. **ロジックを持たない、汎用的な部品・モジュールか?**
   → `design-system/` へ
2. **特定の機能(vertical)専用で、他から使われないか?**
   → その機能の `src/<vertical名>/` 内に置く(index.tsからは公開しない)
3. **複数の機能から使われる、特定用途のコード・部品か?**
   → それ自体を新しいverticalとして独立させる(`src/<新しいvertical名>/`)

## 注意点

- *正しいVertical名・分類*を見極めるのは簡単ではない。チーム内で相談する必要あり
- `index.ts`とのセット運用で、依存関係を明確化する必要あり
- フレームワークごとの差異(Next.jsのApp Router、Nest.jsのモジュール構造等)は「エントリーポイント層」の実装形だけであり、vertical分割の考え方自体はどのTypeScriptプロジェクトでも共通して適用可能
