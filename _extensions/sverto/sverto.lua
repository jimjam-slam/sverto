-- append_to_file: append a string of `content` to the file with the path `name`
function append_to_file(name, content)
  local file = io.open(name, "a")
  if file == nil then
      return ""
  end
  file:write(content)
  file:close()
  return content
end

-- inject_svelte: a pandoc filter that extracts svelte files named in the doc
-- frontmatter and adds javascript blocks to import them as es modules
function inject_svelte_and_compile(m)

  if not quarto.doc.isFormat("html") then
    quarto.log.warning("Sverto shortcode ignored for non-HTML output")
    return nil
  end

  -- no files to process? abort
  if m.sverto == nil or m.sverto.use == nil then
    quarto.log.warning("No Svelte files found. To use Sverto with this document, add a list of .svelte files to the document frontmatter under the `sverto.use` key.")
    return nil
  end

  -- abort if sverto.use is not a list of MetaInlines
  local sverto_use
  if pandoc.utils.type(m.sverto.use) == "List" then
    sverto_use = m.sverto.use
  elseif type(m.sverto.use) == "string" then
    sverto_use = { m.sverto.use }
  else
    quarto.log.error(
      "sverto.use should be Inlines, not " .. 
      pandoc.utils.type(m.sverto.use))
  end

  -- if pandoc.utils.type(m.sverto.use) ~= "List" then
  --   quarto.log.error(
  --     "Sverto error: sverto.use key should be either a string path or " ..
  --     "a list of string paths, not " .. pandoc.utils.type(m.sverto.use))
  -- end

  local sveltePaths = ""

  -- either add text to start of body (and return nil), or return a rawblock
  -- %s: obj_name
  -- %s: file_name, adapted for output path (and .svelte => .js)
  local svelteInitTemplate = [[
    <script type="module">
      // when the doc is ready, find quarto's ojs and inject svelte import
      document.addEventListener("DOMContentLoaded", () => {
        
        import("%s").then(svelteModule => {
          
          const ojsModule = window._ojs?.ojsConnector?.mainModule
          if (ojsModule === undefined) {
            console.error("Quarto OJS module not found")
          }
  
          // TODO - check to see if there's already a variable with that name
          const svertoImport = ojsModule?.variable()
          svertoImport?.define("%s", svelteModule)

        })

      })
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
      obj_name .. ".js"
    })

    -- add path to svelte compiler path list
    sveltePaths = sveltePaths .. in_path .. ":"

    local svelteInsert = string.format(svelteInitTemplate,
    compiled_path, obj_name)

    -- quarto.log.warning("INJECTION:")
    -- quarto.log.warning(svelteInsert)

    quarto.doc.include_text("before-body", svelteInsert)

    -- now run the svelte compiler... if we're not in a project
    if quarto.project.directory ~= nil then
      quarto.log.info("Project found; deferring Svelte compilation to post-render script")
    else
      local svelteCommand =
        "npm run build rollup.config.js -- " ..
        '--configQuartoOutPath="./" ' ..
        '--configSvelteInPaths="' .. sveltePaths .. '"'
      local svelteResult = os.execute(svelteCommand)
      quarto.log.warning("Svelte compiler finished with code " .. tostring(svelteResult))
      
    end
  end

end

return {
  Meta = inject_svelte_and_compile
}
