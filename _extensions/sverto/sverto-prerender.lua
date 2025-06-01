
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

-- offset a relative `svelte_path` to a .qmd `input_path`, or an absolute
-- `svelte_path` to the project path. then normalize.
function offset_svelte_path(svelte_path, input_path)
  
  -- offset from either input .qmd (if relative) or project dir (if absolute)
  -- local offset_from = pandoc.system.get_working_directory()
  local offset_from = "./"
  if pandoc.path.is_relative(svelte_path) then
    -- offset_from = pandoc.path.directory(input_path)
    offset_from = pandoc.path.join({
      offset_from,
      pandoc.path.directory(input_path)
    })
  end
  
  -- join offset and svelt paths
  local relative_path = pandoc.path.join({
    offset_from,
    pandoc.utils.stringify(svelte_path)
  })
  
  -- normalize and return
  local final_path = pandoc.path.normalize(relative_path)
  return final_path
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

      -- confirm sverto.use is a string or list
      if m.sverto == nil or m.sverto.use == nil then
        return nil
      end

      local sverto_use
      if pandoc.utils.type(m.sverto.use) == "List" then
        sverto_use = m.sverto.use
      elseif type(m.sverto.use) == "string" then
        sverto_use = { m.sverto.use }
      else
        print(
          "Sverto error: sverto.use key should be either a string path or " .. "a list of string paths, not " .. pandoc.utils.type(m.sverto.use))
        return nil
      end

      -- add each unique path, resolving relative project location
      for _, svelte_path in ipairs(sverto_use) do
        local offset_path = offset_svelte_path(
          pandoc.utils.stringify(svelte_path),
          input_path)
        svelte_paths[offset_path] = offset_path
      end

    end
  }
  
end

-- load mount.js and rollup.config.js from extension folder
local rollup_config
local svelte_path_string
if file_exists("./_extensions/jimjam-slam/sverto/rollup.config.js") then
  rollup_config = "./_extensions/jimjam-slam/sverto/rollup.config.js"
  svelte_path_string = "./_extensions/jimjam-slam/sverto/mount.svelte"
elseif file_exists("./_extensions/sverto/rollup.config.js") then
  rollup_config = "./_extensions/sverto/rollup.config.js"
  svelte_path_string = "_extensions/sverto/mount.svelte"
else
  print("Error: Sverto extension files not found. " ..
    "Is Sverto installed properly?")
  os.exit(1)
end

-- now concat .svelte paths to mount.js
-- (start with mount.svelte, which is special)
for _, svelte_path in pairs(svelte_paths) do
  svelte_path_string = svelte_path_string ..  ":" .. svelte_path
end


-- this is where mount.svelte will be compiled to as svelte.js
local mount_path_compiled = os.getenv("QUARTO_PROJECT_OUTPUT_DIR") ..
  '/site_libs/sverto/'
pandoc.system.make_directory(mount_path_compiled, true)

cmd =
  get_cmd_prefix() ..
  "npm run build " ..
  rollup_config .. " -- " ..
  '--configQuartoOutPath="' .. os.getenv("QUARTO_PROJECT_OUTPUT_DIR") .. '" ' ..
  '--configSvelteInPaths="' .. svelte_path_string .. '" ' ..
  '--configSvelteMountPath="' .. mount_path_compiled .. '" ' ..
  '--bundleConfigAsCjs'

print("About to compile Svelte using cmd:")
print(cmd)

local svelteResult = os.execute(cmd)

if svelteResult == nil or svelteResult == true then
  print("Sverto pre-render finished!")
else
  print("Svelte compiler finished with code " .. tostring(svelteResult))
end
