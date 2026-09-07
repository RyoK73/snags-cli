import { defineCommand, runMain } from "citty";
import consola from "consola";

const cliVersion = "0.0.1";
const main = defineCommand({
  meta: {
    name: "snags-cli",
    version: cliVersion,
    description: "My Awesome CLI App",
  },
  run() {
    consola.success("Hello!");
  },
});

export default main;
