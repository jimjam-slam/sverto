-- quarto-svelte-prerender.lua
-- james goldie
-- this pre-render script runs when quarto-svelte is installed on a quarto project. it:
-- 1) looks in the doc meta for svelte paths
-- 2) calls the svelte compiler with the svelte paths identified in (1)
-- (injecting the bundled svelte files into the html is handled by quarto-svelte.lua)

-- try to load a module from multiple paths
-- modified version of https://stackoverflow.com/a/17878208/3246758
local function try_require(path_table)
  for _, v in pairs(path_table) do
    ok, err = pcall(require, v)
    if ok then
      return err
    end
  end
  error("Could not find a module to load from selected paths")
end

util = try_require({
  "_extensions.jimjam-slam.quarto-svelte.util",
  "_extensions.quarto-svelte.util",
})

input_paths = os.getenv("QUARTO_PROJECT_INPUT_FILES")

-- walk input files, processing the meta to get the svelte files
-- (make relative paths relative to the input file!)

svelte_paths = {}

-- for _, input_path in ipairs(input_paths) do
for input_path in input_paths:gmatch("[^\n]+") do

  local doc = pandoc.read(util.read_file(input_path), "markdown")

  doc:walk {
    Meta = function(m)

      -- confirm quarto-svelte.use is a string or list
      if m.quarto-svelte == nil or m.quarto-svelte.use == nil then
        return nil
      end

      local quarto-svelte_use = util.get_svelte_paths_from_meta(m)
      -- add each unique path, resolving relative project location
      for _, svelte_path in ipairs(quarto-svelte_use) do
        local offset_path = util.offset_svelte_path(
          pandoc.utils.stringify(svelte_path),
          input_path)
        svelte_paths[offset_path] = offset_path
      end

    end
  }
  
end

-- now concat .svelte paths
local svelte_path_string = ""
for _, svelte_path in pairs(svelte_paths) do
  svelte_path_string = svelte_path_string ..  ":" .. svelte_path
end

util.compile_svelte_files(
  os.getenv("QUARTO_PROJECT_OUTPUT_DIR"),
  svelte_path_string)
