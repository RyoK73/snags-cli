import js from "@eslint/js";
import globals from "globals";
import tseslint from "typescript-eslint";

import { defineConfig, globalIgnores } from "eslint/config";

export default defineConfig([
  globalIgnores(["dist/**", "coverage/**"]),
  tseslint.configs.strictTypeChecked,
  {
    plugins: { js },
    extends: ["js/recommended"],
    files: ["**/*.{ts,mts,cts}"],
    languageOptions: {
      globals: globals.node,
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
  },
  {
    files: ["**/*.test.ts"],
    languageOptions: { globals: { ...globals.node, ...globals.vitest } },
  },
]);
