-- TODO - define global list of file_paths

-- replaces sverto shorcodes with js initialisation code for 
return {
  ['sverto'] = function(args, kwargs) 
    
    if not quarto.doc.isFormat('html') then
      quart.log.warning("Sverto shortcode ignored for non-HTML output")
      return nil
    
    -- cmd args
    local file_path = pandoc.utils.stringify(args[1])
    local file_name = string.match(file_path, "(.-)([^\\/]-%.?([^%.\\/]*))$")[2]
    
    local obj_name = pandoc.utils.stringify(kwargs["name"])
    if obj_name == nil then
        -- obj_name = base name...?
        -- extract path components:
        -- https://stackoverflow.com/a/12191225

    -- assumes svelte will compile to the same relative path
    local output_path = string.sub(input_path, "%.svelte$", ".js")

    -- either add text to start of body (and return nil), or return a rawblock
    -- %s: obj_name
    -- %s: file_name, adapted for output path (and .svelte => .js)
    local svelteInitTemplate = [[
      <script>
        // when the doc is ready, find quarto's ojs and inject svelte import
        document.addEventListener("DOMContentLoaded", () => {
          // TODO - import compiled svelte js file
          %s = await import("%s")

          const ojsModule = window._ojs?.ojsConnector?.mainModule
          if (ojsModule === undefined) {
            console.error("Quarto OJS module not found")
          }
          const svertoImport = ojsModule?.variable()
          svertoImport?.define(%s, %s)
        }
      </script>
    ]]

    local svelteInsert = string.format(svelteInitTemplate,
      obj_name, file_path,
      obj_name, file_path)

    quarto.log.warning("INSERTING")
    quarto.log.warning(svelteInsert)

    quarto.doc.include_text("before-body", svelteInsert)
      
    -- return pandoc.RawBlock("html", svelteInsert)
    return nil
  end
}
