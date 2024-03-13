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
console.log(commandLineArgs)

console.log("Env vars:")
console.log("SVERTO_INPUT_PATHS=" + process.process.env.SVERTO_INPUT_PATHS)
console.log("QUARTO_RENDER_PATH=" + process.process.env.QUARTO_RENDER_PATH)

// we export an array of rollup configs: one for each input svelte file
export default commandLineArgs => {
	if (commandLineArgs.svertoPaths != undefined &&
			commandLineArgs.quartoOutDir != undefined) {

		console.log("Sverto paths found:")
		console.log(commandLineArgs.svertoPaths)
		console.log("Quarto output dir found:")
		console.log(commandLineArgs.quartoOutDir)
		console.log("Returning Svelte compiler config...")

		return uniqueSvelteFiles.map(

			svelteFile => ({
				input: svelteFile,
				output: {
					format: "es",
					dir: path.join(
						quartoOutDir,
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

	} else {
		console.error("Error: need both Svelte input files and Quarto output dir")
	}
}


