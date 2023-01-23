// delete the temporary import block files and the temp render metadata
try {
  await Deno.remove(".sverto/",  { recursive: true })
} catch {

}
