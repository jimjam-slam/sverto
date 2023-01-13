// check if _extensions/svero exists or _extensions/360-info/sverto

import * as path from "https://deno.land/std/path/mod.ts";

const scriptPath = path.fromFileUrl(import.meta.url);
// console.log("Compile file is: " + scriptPath);

const rollupConfig = path.join(path.dirname(scriptPath), "rollup.config.js");

// now call rollup with the config file
const cmd = ["npm", "run", "build", rollupConfig];
const compileStep = Deno.run({ cmd });
await compileStep.status();
// console.log("Svelte compilation + bundling done!");

// let extensionDir = null;

// for await (const dirEntry of Deno.readDir("/_extensions")) {
//   console.log(dirEntry.name);
//   if (dirEntry.name == "sverto") {
//     extensionDir = "_extensions/sverto"
//   } else if (dirEntry.name == "360-info") {
//     // now iterate inside _extensions/360-info
//     extensionDir = "_extensions/sverto"
//   } else {
//     console.error("No sverto extension found ")
//   }
// }
