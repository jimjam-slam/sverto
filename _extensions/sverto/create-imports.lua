-- return contents of named file
function read_file(name)
  local file = io.open(name, "r")
  if file == nil then
      return ""
  end
  local contents = file:read("a")
  file:close()
  return contents
end

-- write content to named file path
function write_file(name, content)
  local file = io.open(name, "w")
  if file == nil then
      return ""
  end
  file:write(content)
  file:close()
  return content
end

function append_to_file(name, content)
  local file = io.open(name, "a")
  if file == nil then
      return ""
  end
  file:write(content)
  file:close()
  return content
end

-- use mkdir (windows) or mkdir -p (*nix) to create directories
-- from https://stackoverflow.com/a/14425862/3246758
function get_path_sep()
  return package.config:sub(1, 1)
end

-- create a folder recursively (mkdir on windows, mkdir -p on *nix)
function create_dir_recursively(path)
  local path_separator = get_path_sep()
  if path_separator == "\\" or path_separator == "\"" then
    os.execute("mkdir " .. path)
  else
    -- macos/linux
    os.execute("mkdir -p " .. path)
  end
end

-- path_dir: extract the folder path from a file path
-- from https://stackoverflow.com/a/9102300/3246758
function path_dir(path)
    return path:match("(.*".. get_path_sep() ..")") or ""
end

-- TODO - 

local preprocess_qmd_filter = {
  
  -- search for `import_svelte("X.svelte")` refs in codeblocks and switch them
  -- to `import("X.js")`
  CodeBlock = function(block)
    if block.classes:includes("{ojs}") then

      local svelte_import_syntax =
        "import%_svelte%(\"([%w;,/%?:@&=%+%$%-_%.!~%*'%(%)#]+)%.svelte\"%)"

      local block_text = block.text

      -- get the qmd_path from disk
      local current_qmd_path = read_file(".sverto/.sverto-current-qmd-folder")

      -- first, extract .svelte paths in import_svelte() statements
      for svelte_path in block_text:gmatch(svelte_import_syntax) do
        append_to_file(".sverto/.sverto-imports",
          current_qmd_path .. svelte_path .. ".svelte\n")
      end

      -- now change `import_svelte("X.svelte")` refs to `import("X.js")`
      -- TODO - neaten up relative paths instead of assuming we're going from
      -- /site_libs/quarto-ojs
      block.text = block_text:gsub(
        svelte_import_syntax,
        "import(\"./../../" .. current_qmd_path .. "%1.js\")")

    end
    return block
  end,

  -- return the doc as a a whole unchanged...
  -- except without the first block (the include statement)
  Pandoc = function(doc)
    local new_blocks = pandoc.Blocks({})
    for i, v in ipairs(doc.blocks) do
      if i ~= 1 then
          new_blocks:insert(v)
      end
    end
    doc.blocks = new_blocks
    return doc

  end
}

create_dir_recursively(".sverto/")

-- collect the input qmd paths
in_file_string = os.getenv("QUARTO_PROJECT_INPUT_FILES")
in_files = {}
for in_file in string.gmatch(in_file_string,  "([^\n]+)") do
  table.insert(in_files, in_file)
end

-- transform each input qmd, saving the transformation in .sverto/[path]
-- (write the identified .svelte files out to a file too!)
for key, qmd_path in ipairs(in_files) do
  
  local doc = pandoc.read(read_file(qmd_path))

  -- store the current qmd_path on disk so the filter can access it
  write_file(".sverto/.sverto-current-qmd-folder", path_dir(qmd_path))
  
  -- pre-process the qmd, populating `svelte_files` in the process
  -- local svelte_files = {}
  local transformed_doc = doc:walk(preprocess_qmd_filter)
  create_dir_recursively(".sverto/" .. path_dir(qmd_path))
  write_file(".sverto/" .. qmd_path, pandoc.write(transformed_doc, "markdown"))
  
end

-- write the output dir path temporarily (so rollup can use it)
write_file(".sverto/.sverto-outdir", os.getenv("QUARTO_PROJECT_OUTPUT_DIR"))

-- TODO - if there's no {{< import .sverto/file.qmd >}} block, add it?
