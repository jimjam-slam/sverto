console.log("PRE-RENDER")

// delete .quarto/.svelte-quarto-matches (it's fine if it doesn't exist already)
try {
  await Deno.remove(".quarto/.svelte-quarto-matches");
} catch (error) {
  if (!(error instanceof Deno.errors.NotFound)) {
    throw error;
  }
}

// write project output path to .quarto/.svelte-output-path
await Deno.writeTextFile(
  ".quarto/.svelte-output-path",
  Deno.env.get("QUARTO_PROJECT_OUTPUT_DIR"),
  {
    append: false
  });
