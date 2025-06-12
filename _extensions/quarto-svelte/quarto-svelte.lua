-- quarto-svelte.lua
-- james goldie
-- this filter runs on individual documents when it's specified. it handles 2–3
-- things:
-- 1) looks in the doc meta for svelte paths
-- 2) adds a vanilla js block to the doc header to initialise the compiled svelte
-- 3) IF the filter is NOT running in a project context (ie. a single doc),
--    call the svelte compiler with the svelte paths identified in (1)
--    (if it is a project, this step is handled by quarto-svelte-prerender.lua across
--    the whole project)

quarto.log.info(">>> quarto-svelte: document filter")

util = require("./util")

-- inject_svelte: a pandoc filter that extracts svelte files named in the doc
-- frontmatter and adds javascript blocks to import them as es modules
function inject_svelte_and_compile(m)

  if not quarto.doc.isFormat("html") then
    quarto.log.warning("quarto-svelte shortcode ignored for non-HTML output")
    return nil
  end

  -- no files to process? abort
  if m["quarto-svelte"] == nil or m["quarto-svelte"].use == nil then
    quarto.log.warning(
      "No Svelte files found under `quarto-svelte.use`. " ..
      "To use quarto-svelte with this document, add a list of .svelte files " .."to the document frontmatter under the `quarto-svelte.use` key.\n\n" ..
      "If you did not intend to use quarto-svelte on this document, " ..
      "consider removing the quarto-svelte filter (you can still use it on " ..
      "other pages of a Quarto website).")
    return nil
  end

  -- either add text to start of body (and return nil), or return a rawblock
  -- %s: compiled svelte js path
  -- %s: obj_name
  local svelte_js_import_template = [[
    <script type="module">

      // when the doc is ready, find quarto's ojs and inject svelte import
      document.addEventListener("DOMContentLoaded", () => {
        
        import("%s").then(svelteModule => {

          const ojsModule = window._ojs?.ojsConnector?.mainModule
          if (ojsModule === undefined) {
            console.error("Quarto OJS module not found")
          }
  
          // TODO - check to see if there's already a variable with that name
          const quartoSvelteImport = ojsModule?.variable()
          quartoSvelteImport?.define("%s", svelteModule)

        })

      })
    </script>
  ]]
  
  -- abort if quarto-svelte.use is not a string or a list of MetaInlines
  local quarto_svelte_use = util.get_svelte_paths_from_meta(m)

  -- now inject the ojs init code for the user's svelte bundles while
  -- building a list of .svelte files to potentially compile
  local svelte_paths_string = ""
  for _, path in ipairs(quarto_svelte_use) do
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
    svelte_paths_string = svelte_paths_string .. in_path .. ":"

    -- ... and inject the ojs init code for it
    local svelte_insert = string.format(svelte_js_import_template,
      compiled_path, obj_name)
    quarto.doc.include_text("before-body", svelte_insert)

    -- finally, if we're rendering a single doc (not in a project),
    -- compile the svelte file to a js bundle
    if quarto.project.directory ~= nil then
      quarto.log.debug("Project found; deferring Svelte compilation to pre-render script")
    else
      util.compile_svelte_files("./", svelte_paths_string) 
    end
  end
end

return {
  Meta = inject_svelte_and_compile
}
