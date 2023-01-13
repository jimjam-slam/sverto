-- ref: https://pandoc.org/lua-filters.html#pandoc-module

-- create .sverto
os.execute("mkdir .sverto/")

-- get the input files

in_file_string = os.getenv("QUARTO_PROJECT_INPUT_FILES")
in_files = {}
for in_file in string.gmatch(in_file_string,  "([^\n]+)") do
  table.insert(in_files, in_file)
end

-- print("--------------")
-- print(">>> PRERENDER")
-- print("Files going in:")
-- print(in_file_string)
-- print("--------------")

-- test case: single file (we want to do this for all files!)

first_file_name = in_files[1]

first_file = io.open(first_file_name, "r")
-- print(">>> PRERENDER: CONTENT OF FIRST FILE: " .. first_file_name)
first_file_contents = pandoc.read(io.output(first_file):read("a"))
-- print(first_file_contents)

-- check if there's svelte in the frontmatter


svelte_key = first_file_contents.meta["svelte"]

if (svelte_key) then
  -- print("Found a svelte key in the frontmatter")
  import_block = "```{ojs}\n"
  for i, item in ipairs(svelte_key) do
    -- TODO - assert item is a pandoc string
    
    item_string = pandoc.utils.stringify(item)
    item_js = string.sub(item_string, 1, string.len(item_string) - 7)
    -- print("  - " .. item_string .. " => " .. item_js .. ".js")

    -- write the item out to .sverto/.svelte-imports
    import_list_file = io.open(".sverto/.sverto-imports", "a")
    io.output(import_list_file):write(item_string .. "\n")
    print("Added to .sverto/.sverto-imports")
    io.close(import_list_file)

    -- add the item to the require block
    -- print(">>>>>> Next item:")
    -- print(item_js .. ".js")
    import_block = import_block ..
      item_js .. " = import(\"/" .. item_js ..".js\")\n"

  end
  
  -- write the import block out to .sverto/[path]
  import_block = import_block .. "```"
  -- print("Import block:")
  -- print(import_block)
  -- print("Writing out to " .. ".sverto/" .. first_file_name)
  import_file = io.open(".sverto/" .. first_file_name, "w")
  io.output(import_file):write(import_block .. "\n")
  io.close(import_file)
else
  -- print("No svelte key in " .. first_file_name)
end

-- write the output dir temporarily
outdir_file = io.open(".sverto/.sverto-outdir", "w")
io.output(outdir_file):write(
  os.getenv("QUARTO_PROJECT_OUTPUT_DIR"))
io.close(outdir_file)

-- TODO - if there's no {{< import .sverto/file.qmd >}} block, add it
