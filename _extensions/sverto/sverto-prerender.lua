
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

-- get a prefix for calling npm run based on windows or *nix/macos
-- using path separator: i don't know pandoc.system.os() values
function get_cmd_prefix()
  if pandoc.path.separator == "\\" then
    return "cmd /c "
  else
    return ""
  end
end

-- create a folder recursively (mkdir on windows, mkdir -p on *nix)
-- function create_dir_recursively(path)
--   if pandoc.path.separator == "\\" or pandoc.path.separator == "\"" then
--     os.execute("mkdir " .. path)
--   else
--     -- macos/linux
--     os.execute("mkdir -p " .. path)
--   end
-- end

-- file_exists: true if the file at `name` exists
-- from https://pandoc.org/lua-filters.html#building-images-with-tikz
function file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

-- break a path up into folders, and if you encounter ".." then remove both that
-- and the preceding piece (unless you're going back past the project root)
function reduce_relative_path(path)

  local split_path = pandoc.path.split(path)
  local reduced_path = {}
  for _, component in pairs(split_path) do
    local component_str = tostring(component)

    -- if you find a ".." in the path and there are folders left to remove,
    -- remove one. otheriwse, add it
    if component_str == ".." and #reduced_path > 0 then
      table.remove(reduced_path)
    else
      table.insert(reduced_path, component_str)
    end
  end

  local final_path = pandoc.utils.stringify(pandoc.path.join(reduced_path))
  return final_path
  
end

-- offset a relative svelte_path to be relative to the project directory, via
-- the .qmd it's in
function offset_svelte_path(svelte_path, input_path)
  
  if not pandoc.path.is_relative(svelte_path) then
    return svelte_path
  end

  -- is relative: join qmd path and svelte path
  local qmd_folder = pandoc.path.directory(input_path)
  local qmd_relative_path = pandoc.path.join({
    pandoc.utils.stringify(qmd_folder),
    pandoc.utils.stringify(svelte_path)
  })

  -- finally reduce any unnecessary ".." out to find duplicates
  return reduce_relative_path(qmd_relative_path)

end

input_paths = os.getenv("QUARTO_PROJECT_INPUT_FILES")

-- walk input files, processing the meta to get the svelte files
-- (make relative paths relative to the input file!)

svelte_paths = {}

-- for _, input_path in ipairs(input_paths) do
for input_path in input_paths:gmatch("[^\n]+") do

  local doc = pandoc.read(read_file(input_path), "markdown")

  doc:walk {
    Meta = function(m)

      if m.sverto == nil or m.sverto.use == nil then
        return nil
      end

      -- single string: add one path
      if type(m.sverto.use) == "string" then
        local offset_path = offset_svelte_path(m.sverto.use, input_path)
        svelte_paths[offset_path] = offset_path
      end

      -- list: add each unique path, offsetting it from its input_path .qmd
      if pandoc.utils.type(m.sverto.use) == "List" then
        for i, svelte_path in ipairs(m.sverto.use) do
          local offset_path = offset_svelte_path(
            pandoc.utils.stringify(svelte_path),
            input_path)
          svelte_paths[offset_path] = offset_path
        end
      end

      return nil

    end
  }
  
end

-- now concatenate them with : and send them to the svelte compiler
svelte_path_string = ""
for _, svelte_path in pairs(svelte_paths) do
  svelte_path_string = svelte_path_string .. svelte_path .. ":"
end

-- finally, call the svelte compiler via rollup
rollup_config = ""
if file_exists("./_extensions/jimjam-slam/sverto/rollup.config.js") then
  rollup_config = "./_extensions/jimjam-slam/sverto/rollup.config.js"
elseif file_exists("./_extensions/sverto/rollup.config.js") then
  rollup_config = "./_extensions/sverto/rollup.config.js"
else
  print("Error: no rollup config found. Is Sverto installed properly?")
  os.exit(1)
end

cmd =
  get_cmd_prefix() ..
  "npm run build " ..
  rollup_config .. " -- " ..
  '--quarto-out-path="' .. os.getenv("QUARTO_PROJECT_OUTPUT_DIR") .. '" ' ..
  '--svelte-in-paths="' .. svelte_path_string .. '"'

print("Preparing to run rollup with command:")
print(cmd)

local svelteResult = os.execute(cmd)

if svelteResult == nil then
  print("Svelte compiler finished!")
else
  print("Svelte compiler finished with code " .. svelteResult)
end
