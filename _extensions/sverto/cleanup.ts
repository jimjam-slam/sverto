// delete the temporary import block files and the temp render metadata
Deno.remove(".sverto/import",  { recursive: true })
Deno.remove(".sverto/.sverto-imports")
Deno.remove(".sverto/.sverto-outdir")
