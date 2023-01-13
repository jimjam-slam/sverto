-- ref: https://pandoc.org/lua-filters.html#pandoc-module

-- delete any existing imports list, since we'll be appending to it
os.remove(".sverto/.sverto-imports")

-- get the input files

in_file_string = os.getenv("QUARTO_PROJECT_INPUT_FILES")
in_files = {}
for in_file in string.gmatch(in_file_string,  "([^\n]+)") do
  table.insert(in_files, in_file)
end

print("--------------")
print(">>> PRERENDER")
print("Files going in:")
print(in_file_string)
print("--------------")

-- test case: single file (we want to do this for all files!)

first_file_name = in_files[1]

first_file = io.open(first_file_name, "r")
print(">>> PRERENDER: CONTENT OF FIRST FILE: " .. first_file_name)
first_file_contents = pandoc.read(io.output(first_file):read("a"))
print(first_file_contents)

-- check if there's svelte in the frontmatter


svelte_key = first_file_contents.meta["svelte"]

if (svelte_key) then
  print("Found a svelte key in the frontmatter")
  import_block = "```{ojs}\n"
  for i, item in ipairs(svelte_key) do
    -- TODO - assert item is a pandoc string
    
    item_string = pandoc.utils.stringify(item)
    item_js = string.sub(item_string, 1, string.len(item_string) - 7) .. ".js"
    print("  - " .. item_string .. " => " .. item_js)

    -- write the item out to .sverto/.svelte-imports
    import_list_file = io.open(".sverto/.sverto-imports", "a")
    io.output(import_list_file):write(item_js .. "\n")
    io.close(import_list_file)

    -- add the item to the require block
    require_block = require_block .. "require(\"" .. item_js .."\")\n"

  end
  
  -- write the require block out to .sverto/[path]
  require_block = require_block .. "```"
  print("Require block:")
  print(require_block)
  import_file = io.open(".sverto/" .. first_file_name, "w")
  io.output(import_file):write(require_block .. "\n")
  io.close(import_file)
else
  print("No svelte key in " .. first_file_name)
end

-- if there is and there's no {{< import .sverto/file.qmd >}}, add it
-- print(first_file_contents.blocks[1]) -- should be the import!