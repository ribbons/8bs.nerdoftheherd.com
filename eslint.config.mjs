import js from "@eslint/js";
import globals from "globals";
import { defineConfig } from "eslint/config";

export default defineConfig([
  {
    files: [
      "common/script/*.js",
      "eslint.config.mjs",
    ],
    plugins: { js },
    extends: ["js/recommended"],
  },
  {
    files: [
      "common/script/*.js",
    ],
    languageOptions: {
      sourceType: "script",
      globals: {
        ...globals.browser,
        ...globals.jquery,
      },
    },
  },
]);
