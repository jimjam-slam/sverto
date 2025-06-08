
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

function get_svelte_paths_from_meta(m)
  local sverto_use
  if pandoc.utils.type(m.sverto.use) == "List" then
    sverto_use = m.sverto.use
  elseif type(m.sverto.use) == "string" then
    sverto_use = { m.sverto.use }
  else
    quarto.log.error(
      "sverto.use should be Inlines, not " .. 
      pandoc.utils.type(m.sverto.use))
  end
  return sverto_use
end

function compile_svelte_files(quarto_out_path, svelte_paths_string)
  -- first, find the rollup config
  local rollup_config
    if file_exists("./_extensions/jimjam-slam/sverto/rollup.config.js") then
      rollup_config = "./_extensions/jimjam-slam/sverto/rollup.config.js"
    elseif file_exists("./_extensions/sverto/rollup.config.js") then
      rollup_config = "./_extensions/sverto/rollup.config.js"
    else
      print("Error: Sverto extension files not found. " ..
      "Is Sverto installed properly?")
      os.exit(1)
    end

    local svelte_command =
      "npm run build " .. rollup_config .. " -- " ..
      '--configQuartoOutPath="' .. quarto_out_path .. '" ' ..
      '--configSvelteInPaths="' .. svelte_paths_string .. '" ' ..
      '--bundleConfigAsCjs'
    
    local rollup_result = os.execute(svelte_command)
    if rollup_result == nil or rollup_result == true then
      print("Sverto compiler finished!")
    else
      print("Svelte compiler exited with code " .. tostring(rollup_result))
    end
end

return {
  read_file = read_file,
  get_cmd_prefix = get_cmd_prefix,
  file_exists = file_exists,
  offset_svelte_path = offset_svelte_path,
  get_svelte_paths_from_meta = get_svelte_paths_from_meta,
  compile_svelte_files = compile_svelte_files }