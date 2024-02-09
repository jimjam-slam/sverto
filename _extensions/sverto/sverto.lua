
function append_to_file(name, content)
  local file = io.open(name, "a")
  if file == nil then
      return ""
  end
  file:write(content)
  file:close()
  return content
end

function inject_svelte(m)

  quarto.log.warning("PROCESSING DOC")
  quarto.log.warning("Profile:")
  quarto.log.warning(quarto.project.profile)
  quarto.log.warning("Project dir")
  quarto.log.warning(quarto.project.directory)
  quarto.log.warning("Project output dir")
  quarto.log.warning(quarto.project.output_directory)
  quarto.log.warning("Offset (curr. doc rel. project root)")
  quarto.log.warning(quarto.project.offset)
  quarto.log.warning("Doc in path")
  quarto.log.warning(quarto.doc.input_file)
  quarto.log.warning("Doc out path")
  quarto.log.warning(quarto.doc.output_file)

  quarto.log.warning("Path separator is:")
  local sep = pandoc.path.separator

  -- quarto.log.warning("DOC META:")
  -- quarto.log.warning(m)

  if not quarto.doc.isFormat('html') then
    quarto.log.warning("Sverto shortcode ignored for non-HTML output")
    return nil
  end

  -- no files to process? abort
  if m.sverto == nil or m.sverto.use == nil then
    quarto.log.warning("Define sverto.use in frontmatter")
    return nil
  end

  -- quarto.log.warning("sverto.use:")
  -- quarto.log.warning(m.sverto.use)

  -- abort if sverto.use is not a list of MetaInlines
  if pandoc.utils.type(m["sverto"]["use"]) ~= "List" then
    quarto.log.error(
      "sverto.use should be Inlines, not " .. 
      pandoc.utils.type(m["sverto"]["use"]))
  end

  -- either add text to start of body (and return nil), or return a rawblock
  -- %s: obj_name
  -- %s: file_name, adapted for output path (and .svelte => .js)
  local svelteInitTemplate = [[
    <script>
      // when the doc is ready, find quarto's ojs and inject svelte import
      document.addEventListener("DOMContentLoaded", () => {
        %s = await import("%s")

        const ojsModule = window._ojs?.ojsConnector?.mainModule
        if (ojsModule === undefined) {
          console.error("Quarto OJS module not found")
        }

        // TODO - check to see if there's already a variable with that name
        const svertoImport = ojsModule?.variable()
        svertoImport?.define("%s", %s)
      }
    </script>
  ]]

  for _, path in ipairs(m.sverto.use) do
    -- this is where we process the path

    local in_path  = pandoc.utils.stringify(path)
    local in_dir   = pandoc.path.directory(in_path)
    local in_name  = pandoc.path.filename(in_path)
    local obj_name = pandoc.path.split_extension(in_name)
    local compiled_path = pandoc.path.join({
      in_dir,
      obj_name .. ".sverto.js"
    })
  
    quarto.log.warning("Processing: " .. in_path ..
      " => " .. compiled_path)

    local svelteInsert = string.format(svelteInitTemplate,
      obj_name, compiled_path, obj_name, obj_name)

    quarto.log.warning("INJECTION:")
    quarto.log.warning(svelteInsert)

    quarto.doc.include_text("before-body", svelteInsert)

    -- now run the svelte compiler... if we're not in a project
    -- (use quarto.project.[directory or output_directory])
    -- os.execute("")
    quarto.log.warning("TODO - compile svelte imports")
  end

end

return {
  Meta = inject_svelte
}
