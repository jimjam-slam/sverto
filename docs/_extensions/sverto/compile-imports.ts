// check if _extensions/svero exists or _extensions/360-info/sverto

import * as path from "https://deno.land/std/path/mod.ts";

const thisScript = path.fromFileUrl(import.meta.url);
const rollupConfig = path.join(path.dirname(thisScript), "rollup.config.js");

// call rollup with the config file
const cmd = ["npm", "run", "build", rollupConfig];
const compileStep = Deno.run({ cmd });
await compileStep.status();

// console.log("Svelte compilation + bundling done!");
