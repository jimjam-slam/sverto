-- sverto.lua
-- this filter runs on individual documents when it's specified. it handles 2–3
-- things:
-- 1) looks in the doc meta for svelte paths
-- 2) adds a vanilla js block to the doc header to initialise the compiled svelte
-- 3) IF the filter is NOT running in a project context (ie. a single doc),
--    call the svelte compiler with the svelte paths identified in (1)
--    (if it is a project, this step is handled by sverto-prerender.lua across
--    the whole project)

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

  -- either add text to start of body (and return nil), or return a rawblock
  -- %s: compiled svelte js path
  -- %s: obj_name
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

  -- now inject the ojs init code for the user's svelte bundles while
  -- buildinga list of .svelte files to potentially compile
  local sveltePaths = ""
  for index, path in ipairs(m.sverto.use) do
    -- this is where we process the other .svelte paths
    local in_path  = pandoc.utils.stringify(path)
    local in_dir   = pandoc.path.directory(in_path)
    local in_name  = pandoc.path.filename(in_path)
    local obj_name = pandoc.path.split_extension(in_name)
    local compiled_path = pandoc.path.join({
      in_dir,
      obj_name .. ".js"
    })

    -- add .svelte path to svelte compiler path list...
    sveltePaths = sveltePaths .. in_path .. ":"

    -- ... and inject the ojs init code for it
    local svelte_insert = string.format(svelteInitTemplate,
      compiled_path, obj_name)
    quarto.doc.include_text("before-body", svelte_insert)

    -- now run the svelte compiler... if we're not in a project
    -- (if we are, let the prerender script handle that step)

    -- finally, if we're rendering a single doc (not in a project),
    -- compile the svelte file to a js bundle
    if quarto.project.directory ~= nil then
      quarto.log.debug("Project found; deferring Svelte compilation to pre-render script")
    else
      local svelteCommand =
        "npm run build rollup.config.js -- " ..
        '--configQuartoOutPath="./" ' ..
        '--configSvelteInPaths="' .. sveltePaths .. '" ' ..
        '--bundleConfigAsCjs'
      local svelteResult = os.execute(svelteCommand)
      quarto.log.debug("Svelte compiler finished with code " .. svelteResult)
      
    end
  end
end

return {
  Meta = inject_svelte_and_compile
}
