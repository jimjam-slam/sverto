console.log("PRE-RENDER")

// delete .quarto/.svelte-quarto-matches (it's fine if it doesn't exist already)
try {
  await Deno.remove(".quarto/.svelte-quarto-matches");
} catch (error) {
  if (!(error instanceof Deno.errors.NotFound)) {
    throw error;
  }
}
