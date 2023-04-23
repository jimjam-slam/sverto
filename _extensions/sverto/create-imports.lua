-- create-imports: a project pre-render script that:
-- * replaces svelte_import() ojs statements in qmd files, saving to /.sverto
-- * writes svelte import paths to /.sverto s othey can be compiled

-- some content from quarto's qmd-reader.lua
-- (c) 2023 rstudio, pbc. licensed under gnu gpl v2:
-- https://github.com/quarto-dev/quarto-cli/blob/main/COPYRIGHT

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

-- content following from quarto's qmd-reader.lua
-- (c) 2023 rstudio, pbc. licensed under gnu gpl v2:
-- https://github.com/quarto-dev/quarto-cli/blob/main/COPYRIGHT

function random_string(size)
  -- we replace invalid tags with random strings of the same size
  -- to safely allow code blocks inside pipe tables
  -- note that we can't use uppercase letters here
  -- because pandoc canonicalizes classes to lowercase.
  local chars = "abcdefghijklmnopqrstuvwxyz"
  local lst = {}
  for _ = 1,size do
    local ix = math.random(1, #chars)
    table.insert(lst, string.sub(chars, ix, ix))
  end
  return table.concat(lst, "")
end

function find_invalid_tags(str)
  -- [^.=\n]
  --   we disallow "." to avoid catching {.python}
  --   we disallow "=" to avoid catching {foo="bar"}
  --   we disallow "\n" to avoid multiple lines

  -- no | in lua patterns...

  -- (c standard, 7.4.1.10, isspace function)
  -- %s catches \n and \r, so we must use [ \t\f\v] instead

  local patterns = {
    "^[ \t\f\v]*(```+[ \t\f\v]*)(%{+[^.=\n\r]*%}+)", 
    "\n[ \t\f\v]*(```+[ \t\f\v]*)(%{+[^.=\n\r]+%}+)"
  }
  local function find_it(init)
    for _, pattern in ipairs(patterns) do
      local range_start, range_end, ticks, tag = str:find(pattern, init)
      if range_start ~= nil then
        return range_start, range_end, ticks, tag
      end
    end
    return nil
  end

  local init = 1
  local range_start, range_end, ticks, tag = find_it(init)
  local tag_set = {}
  local tags = {}
  while tag ~= nil do
    init = range_end + 1
    if not tag_set[tag] then
      tag_set[tag] = true
      table.insert(tags, tag)
    end
    range_start, range_end, ticks, tag = find_it(init)
  end
  return tags
end

function escape_invalid_tags(str)
  local tags = find_invalid_tags(str)
  -- we must now replace the tags in a careful order. Specifically,
  -- we can't replace a key that's a substring of a larger key without
  -- first replacing the larger key.
  --
  -- ie. if we replace {python} before {{python}}, Bad Things Happen.
  -- so we sort the tags by descending size, which suffices
  table.sort(tags, function(a, b) return #b < #a end)

  local replacements = {}
  for _, k in ipairs(tags) do
    local replacement
    local attempts = 1
    repeat
      replacement = random_string(#k)
      attempts = attempts + 1
    until str:find(replacement, 1, true) == nil or attempts == 100
    if attempts == 100 then
      print("Internal error, could not find safe replacement for "..k.." after 100 tries")
      print("Please file a bug at https://github.com/quarto-dev/quarto-cli")
      os.exit(1)
    end
    -- replace all lua special pattern characters with their
    -- escaped versions
    local safe_pattern = k:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
    replacements[replacement] = k
    local patterns = {
      "^([ \t\f\v]*```+[ \t\f\v]*)" .. safe_pattern,
      "(\n[ \t\f\v]*```+[ \t\f\v]*)" .. safe_pattern
    }

    str = str:gsub(patterns[1], "%1" .. replacement):gsub(patterns[2], "%1" .. replacement)
  end
  return str, replacements
end

function unescape_invalid_tags(str, tags)
  for replacement, k in pairs(tags) do
    -- replace all lua special replacement characters with their
    -- escaped versions, so that when we restore the behavior,
    -- we don't accidentally create a pattern
    local result = k:gsub("([$%%])", "%%%1")
    str = str:gsub(replacement, result)
  end
  return str
end

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

  -- before we read the file in with pandoc.read, let's read it in as a raw
  -- string and do the quarto team's qmd-reader processing on it. THEN we can
  -- read it with pandoc.read

  print(">>> PROCESSING " .. qmd_path)

  local raw_doc = read_file(qmd_path)

  -- store the current qmd_path on disk so the filter can access it
  write_file(".sverto/.sverto-current-qmd-folder", path_dir(qmd_path))

  -- escape invalid tags
  local txt, tags = escape_invalid_tags(tostring(raw_doc))

  -- some extension + format stuff that we can maybe ignore?
  
  -- for k, v in pairs(opts.extensions) do
  --   extensions[v] = true
  -- end

  -- if param("user-defined-from") then
  --   local user_format = _quarto.format.parse_format(param("user-defined-from"))
  --   for k, v in pairs(user_format.extensions) do
  --     extensions[k] = v
  --   end
  -- end

  -- -- Format flavor, i.e., which extensions should be enabled/disabled
  -- local flavor = {
  --   format = "markdown",
  --   extensions = extensions,
  -- }

  local function restore_invalid_tags(tag)
    return tags[tag] or tag
  end

  -- NOW we read in with pandoc (hopefully ending up with real code blocks)
  -- and restore them
  -- local doc = pandoc.read(txt, flavor, opts):walk {
  local doc = pandoc.read(txt, "markdown")
  
  local restored_doc = doc:walk {
    CodeBlock = function (cb)
      cb.classes = cb.classes:map(restore_invalid_tags)
      cb.text = unescape_invalid_tags(cb.text, tags)
      return cb
    end
  }

  -- local doc = pandoc.read(read_file(qmd_path))
  
  -- pre-process the qmd, populating `svelte_files` in the process
  -- local svelte_files = {}
  local transformed_doc = restored_doc:walk(preprocess_qmd_filter)
  create_dir_recursively(".sverto/" .. path_dir(qmd_path))
  write_file(".sverto/" .. qmd_path, pandoc.write(transformed_doc, "markdown"))
  
end

-- write the output dir path temporarily (so rollup can use it)
write_file(".sverto/.sverto-outdir", os.getenv("QUARTO_PROJECT_OUTPUT_DIR"))

-- TODO - if there's no {{< import .sverto/file.qmd >}} block, add it?

