
print(">>> PRERENDER")
os.execute("pwd")
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
  "_extensions.jimjam-slam.sverto.util",
  "_extensions.sverto.util",
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

      -- confirm sverto.use is a string or list
      if m.sverto == nil or m.sverto.use == nil then
        return nil
      end

      local sverto_use = util.get_svelte_paths_from_meta(m)
      -- add each unique path, resolving relative project location
      for _, svelte_path in ipairs(sverto_use) do
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
