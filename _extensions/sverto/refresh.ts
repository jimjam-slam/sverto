// delete the temporary import block files and the temp render metadata

if (Deno.env.get("QUARTO_PROJECT_RENDER_ALL") == "1") {
  try {
    await Deno.remove(".sverto/",  { recursive: true })
  } catch {
  
  }
}

