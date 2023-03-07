// delete the temporary import block files and the temp render metadata

if (Deno.env.get("QUARTO_PROJECT_RENDER_ALL") == "1") {
  try {
    await Deno.remove(".sverto/",  { recursive: true })
  } catch {
  
  }
}

// generate a tsconfig.json based that includes the quarto output dir
const outputDir = Deno.env.get("QUARTO_PROJECT_OUTPUT_DIR");
const tsconfig = `{
  "extends": "@tsconfig/svelte/tsconfig.json",

  "include": ["**/*.svelte"],
  "exclude": [
    "node_modules/*",
    "__sapper__/*",
    ".quarto/*",
    ".sverto/*",
    "_extensions/sverto/*",
    "_extensions/360-info/sverto/*", 
    "${outputDir}/*"
  ]
}`;
const tsconfigPath =  path.join(projectRoot, "tsconfig.json");
Deno.writeTextFileSync(tsconfigPath, tsconfig);