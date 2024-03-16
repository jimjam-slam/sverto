import svelte from 'rollup-plugin-svelte'
import commonjs from '@rollup/plugin-commonjs'
import resolve from '@rollup/plugin-node-resolve'
import { terser } from 'rollup-plugin-terser'

const path = require('node:path')

// this is false when we run rollup with -w/--watch (never presently)
const production = !process.env.ROLLUP_WATCH;


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

/* export an array of rollup configs: one for each input svelte file */

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
	})

)



