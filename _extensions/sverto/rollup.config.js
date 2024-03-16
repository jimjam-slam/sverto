import svelte from 'rollup-plugin-svelte';
import commonjs from '@rollup/plugin-commonjs';
import resolve from '@rollup/plugin-node-resolve';
import { terser } from 'rollup-plugin-terser';

const fs = require('fs');
const path = require('node:path');

// this is false when we run rollup with -w/--watch (never presently)
const production = !process.env.ROLLUP_WATCH;

// get quarto project output directory and list of inputs
// const quartoOutDir = fs.readFileSync('.sverto/.sverto-outdir', 'utf8');

// TODO - get sverto imports from env var SVERTO_IMPORT_PATHS
// instead
// const svelteImportListPath = '.sverto/.sverto-imports';

// skip svelte compilation if there's nothing to compile
// if (!fs.existsSync(svelteImportListPath)) {
// 	console.log("ℹ No Svelte imports to process; skipping compilation");
// 	process.exit();
// }
  
// get the list of unique imports to compile
// const svelteFiles = fs.readFileSync(svelteImportListPath, 'utf8')
// 	.split("\n")
// 	.filter(d => d !== "");
// const uniqueSvelteFiles = [... new Set(svelteFiles)]

console.log("Command line args:")
console.log(process.argv)

/* get svelte input paths (split by :) from cmd line arg */

const svelteInputPaths = process.argv
	.filter(d => d.startsWith("--svelte-in-paths="))
	.map(d => d.replace("--svelte-in-paths=", ""))
	.join(":")
	.split(":")

// if no svelte paths, bail out early
if (svelteInputPaths == undefined || svelteInputPaths.length == 0) {
	console.log("No Svelte filtes found; skipping Svelte compilation")
	Deno.exit(0)
}

/* get quarto render dir from cmd line arg */

let quartoRenderPath = process.argv
	.filter(d => d.startsWith("--quarto-out-path="))
	.map(d => d.replace("--quarto-out-path=", ""))

if (quartoRenderPath == undefined || quartoRenderPath.length != 1) {
	console.error("There should be 1 --quarto-out-path argument.")
}
quartoRenderPath = quartoRenderPath[0]

// we export an array of rollup configs: one for each input svelte file
// export default process.argv => {
// 		return svelteInputPaths.map(

export default svelteInputPaths.map(

			svelteFile => ({
				input: svelteFile,
				output: {
					format: "es",
					dir: path.join(
						quartoRenderPath,
						path.dirname(svelteFile)),
					sourcemap: true
				},
				plugins: [
					svelte({
						// css is added to the js bundle instead
						emitCss: false,
						compilerOptions: {
							// required for ojs reactivity
							accessors: true,
							dev: !production,
						}
					}),
					resolve({
						browser: true,
						dedupe: ["svelte"]
					}),
					commonjs(),
					production && terser()
				]
			}))

// }


