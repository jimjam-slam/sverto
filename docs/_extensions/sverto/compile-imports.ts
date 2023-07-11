// check if _extensions/svero exists or _extensions/360-info/sverto

import * as path from "https://deno.land/std/path/mod.ts";

const thisScript = path.fromFileUrl(import.meta.url);
const rollupConfig = path.join(path.dirname(thisScript), "rollup.config.js");

// run svelte compiler via rollup
// (prepend cmd /c to the command on windows)
const cmdPrefix = Deno.build.os == "windows" ? ["cmd", "/c"] : []
const cmd = cmdPrefix.concat(["npm", "run", "build", rollupConfig]);

// call rollup with the config file
const compileStep = Deno.run({ cmd });
await compileStep.status();
