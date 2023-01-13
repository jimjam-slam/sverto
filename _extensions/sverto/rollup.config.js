import svelte from 'rollup-plugin-svelte';
import commonjs from '@rollup/plugin-commonjs';
import resolve from '@rollup/plugin-node-resolve';
// import livereload from 'rollup-plugin-livereload';
import { terser } from 'rollup-plugin-terser';
import css from 'rollup-plugin-css-only';

const fs = require('fs');
const path = require('node:path');

// this is false when we run rollup with -w/--watch (never presently)
const production = !process.env.ROLLUP_WATCH;

// function serve() {
// 	let server;

// 	function toExit() {
// 		if (server) server.kill(0);
// 	}	

// 	return {
// 		writeBundle() {
// 			if (server) return;
// 			server = require('child_process').spawn('npm', ['run', 'start', '--', '--dev'], {
// 				stdio: ['ignore', 'inherit', 'inherit'],
// 				shell: true
// 			});

// 			process.on('SIGTERM', toExit);
// 			process.on('exit', toExit);
// 		}
// 	};
// }

// get quarto project output directory and list of inputs
// const quartoOutDir = process.env.QUARTO_PROJECT_OUTPUT_DIR;
const quartoOutDir = fs.readFileSync('.sverto/.sverto-outdir', 'utf8')
const svelteFiles = fs.readFileSync('.sverto/.sverto-imports', 'utf8')
	.split("\n")
	.filter(d => d !== "");

// remove duplicate svelte components (being used by several qmds)
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
				compilerOptions: {
					accessors: true,
					dev: !production,
				}
			}),
			css({
				output: path.join(
					quartoOutDir,
					path.dirname(svelteFile),
					path.basename(svelteFile, ".svelte") + ".css")
			}),
			resolve({
				browser: true,
				dedupe: ["svelte"]
			}),
			commonjs(),
			// !production && serve(),
			// !production && livereload("public"),
			production && terser()
		]//,
		// watch: {
		// 	clearScreen: false
		// }
	}));
