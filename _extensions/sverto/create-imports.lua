-- ref: https://pandoc.org/lua-filters.html#pandoc-module

-- use mkdir (windows) or mkdir -p (*nix) to create directories
-- from https://stackoverflow.com/a/14425862/3246758
function get_path_sep()
  return package.config:sub(1, 1)
end

function create_dir_recursively(path)
  print("Creating " .. path)
  local path_separator = get_path_sep()
  if path_separator == "\\" or path_separator == "\"" then
    -- windows
    -- NOTE - there is one edge case where folders might not be made
    -- recursively, https://www.robvanderwoude.com/cmdextmsg.php
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

-- create .sverto
create_dir_recursively(".sverto/")

-- get the input files as a table
in_file_string = os.getenv("QUARTO_PROJECT_INPUT_FILES")
in_files = {}
for in_file in string.gmatch(in_file_string,  "([^\n]+)") do
  table.insert(in_files, in_file)
end

-- create_imports: given a quarto doc path, writes the svelte import
-- declarations to .svelte/[path]
function create_imports(quarto_doc_name)
  local doc_handle = io.open(quarto_doc_name, "r")
  local doc_content = pandoc.read(io.output(doc_handle):read("a"))
  
  -- check if there's svelte in the frontmatter
  
  local svelte_key = doc_content.meta["svelte"]
  
  if (svelte_key) then
    local import_block = "```{ojs}\n"

    -- write each svelte file in this doc's  frontmatter out to
    -- (a) the require block of this doc, and
    -- (b) the global imports file going to the svelte compiler
    for i, item in ipairs(svelte_key) do
      -- TODO - assert item is a pandoc string
      
      local item_string = pandoc.utils.stringify(item)
      local item_js = string.sub(item_string, 1, string.len(item_string) - 7)
      
      -- write the item out to .sverto/.svelte-imports
      local import_list_file = io.open(".sverto/.sverto-imports", "a")
      io.output(import_list_file):write(item_string .. "\n")
      io.close(import_list_file)
  
      -- add the item to the require block
      import_block = import_block ..
        item_js .. " = import(\"/" .. item_js ..".js\")\n"
  
    end
    
    -- write the import block (inc. the final backticks) out to .sverto/[path]
    create_dir_recursively(".sverto/" .. path_dir(quarto_doc_name))
    local import_block = import_block .. "```"
    local import_file = io.open(".sverto/" .. quarto_doc_name, "w")
    io.output(import_file):write(import_block .. "\n")
    io.close(import_file)
  end
end

-- create the imports for each quarto doc
for key, value in ipairs(in_files) do
  create_imports(value)
end

-- write the output dir path temporarily (so rollup can use it)
outdir_file = io.open(".sverto/.sverto-outdir", "w")
io.output(outdir_file):write(
  os.getenv("QUARTO_PROJECT_OUTPUT_DIR"))
io.close(outdir_file)

-- TODO - if there's no {{< import .sverto/file.qmd >}} block, add it
