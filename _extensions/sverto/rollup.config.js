import svelte from "rollup-plugin-svelte"
import commonjs from "@rollup/plugin-commonjs"
import resolve from "@rollup/plugin-node-resolve"
import terser from "@rollup/plugin-terser"

const path = require('node:path')

// this is false when we run rollup with -w/--watch (never presently)
const production = !process.env.ROLLUP_WATCH;

/* export an array of rollup configs - one for each input svelte file - using
   additional command line args supplied from lua */
export default cmd => {

	const svelteInputPaths =
		cmd["configSvelteInPaths"].split(":").filter(d => d != "")

	// if no svelte paths, bail out early
	if (svelteInputPaths == undefined || svelteInputPaths.length == 0) {
		console.log("No Svelte filtes found; skipping Svelte compilation")
		process.exit(0)
	}

	/* get quarto render dir from cmd line arg */
	const quartoRenderPath = cmd["configQuartoOutPath"]
	if (quartoRenderPath == undefined) {
		console.error(
			"Error: supply a --configQuartoOutPath. Please report this to " +
			"the Sverto developer.")
		process.exit(1)
	}

	return svelteInputPaths.map(

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

}




