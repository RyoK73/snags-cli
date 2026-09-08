import { defineConfig } from "vitest/config";

export default defineConfig({
  plugins: [], // プラグイン
  test: {
    globals: true, // it,expect,describeなどのグローバル化,renderの自動クリーンアップ
    env: {
      DEBUG_PRINT_LIMIT: "100",
    },
    reporters: ["verbose"], // vitestの表示方式
  },
  resolve: { tsconfigPaths: true }, // path(@)の解決
});
