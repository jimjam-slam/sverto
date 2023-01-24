import svelte from 'rollup-plugin-svelte';
import commonjs from '@rollup/plugin-commonjs';
import resolve from '@rollup/plugin-node-resolve';
import { terser } from 'rollup-plugin-terser';

const fs = require('fs');
const path = require('node:path');

// this is false when we run rollup with -w/--watch (never presently)
const production = !process.env.ROLLUP_WATCH;

// get quarto project output directory and list of inputs
const quartoOutDir = fs.readFileSync('.sverto/.sverto-outdir', 'utf8');

const svelteImportListPath = '.sverto/.sverto-imports';

// skip svelte compilation if there's nothing to compile
if (!fs.existsSync(svelteImportListPath)) {
	console.log("ℹ No Svelte imports to process; skipping compilation");
	process.exit();
}
  
// get the list of unique imports to compile
const svelteFiles = fs.readFileSync(svelteImportListPath, 'utf8')
	.split("\n")
	.filter(d => d !== "");
const uniqueSvelteFiles = [... new Set(svelteFiles)]

// we export an array of rollup configs: one for each input svelte file
export default uniqueSvelteFiles.map(
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
	}));
