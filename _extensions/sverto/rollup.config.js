import svelte from "rollup-plugin-svelte"
import commonjs from "@rollup/plugin-commonjs"
import { nodeResolve } from "@rollup/plugin-node-resolve"
import terser from "@rollup/plugin-terser"
import { existsSync, mkdirSync } from "node:fs"

const path = require("node:path")

console.log("Exporting Rollup config")

// this is false when we run rollup with -w/--watch (never presently)
const production = !process.env.ROLLUP_WATCH

/* export an array of rollup configs - one for each input svelte file - using
   additional command line args supplied from lua */
export default cmd => {

	console.log("Rollup config: starting")

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

	/* create a directory for mount.js to land in */
	mkdirSync(path.join(quartoRenderPath, "_sverto"), {
		recursive: true
	}) 

	/* look for mount.svelte in extensions dir, as we must compile that too */
	const namespacedExtPath = path.join("_extensions", "jimjam-slam", "sverto")
	const nonNamespacedExtPath = path.join("_extensions", "sverto")
	let mountPath
	if (existsSync(namespacedExtPath)) {
		mountPath = path.join(namespacedExtPath, "mount.svelte")
	} else if (existsSync(nonNamespacedExtPath)) {
		mountPath = path.join(nonNamespacedExtPath, "mount.svelte")
	} else {
		console.error(
			"Error: sverto extension directory not found. Please report this error to the developers at https://github.com/jimjam-slam/sverto.")
		process.exit(1)
	}

	
	// send a rollup config for each svelte file
	// the first is handled specially: it is assumed to be mount.svelte and is
	// compiled to a file/project js folder given by the lua caller
	const pathsToCompile = [mountPath, ...svelteInputPaths]
	console.log("Rollup config: returning")
	return pathsToCompile.map(

		(svelteFile, index) => ({
			input: svelteFile,
			output: {
				format: "es",
				dir: index == 0 ?
					cmd["configSvelteMountPath"] :
					path.join(quartoRenderPath, path.dirname(svelteFile)),
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
				nodeResolve({
					browser: true,
					dedupe: ["svelte"]
				}),
				commonjs(),
				production && terser()
			]
		})

	)

}




