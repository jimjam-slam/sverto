
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

-- use mkdir (windows) or mkdir -p (*nix) to create directories
-- from https://stackoverflow.com/a/14425862/3246758
function get_path_sep()
  return package.config:sub(1, 1)
end

-- get a prefix for calling npm run based on windows or *nix/macos
-- using path separator: i don't know pandoc.system.os() values
function get_cmd_prefix()
  if get_path_sep() == "\\" then
    return "cmd /c "
  else
    return ""
  end
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

-- offset a relative svelte_path to be relative to the
-- input_path
function offset_svelte_path(svelte_path, input_path)
  
  if not pandoc.path.is_relative(svelte_path) then
    return svelte_path
  end

  -- is relative: offset
  local offset_path =
    pandoc.path.make_relative(svelte_path, input_path, false)
  quarto.log.info("Offsetting svelte path from qmd: " .. input_path .. " + " .. svelte_path .. " => " ..
    offset_path)
  return offset_path

end

input_paths = os.getenv("QUARTO_PROJECT_INPUT_FILES")

-- walk input files, processing the meta to get the svelte files
-- (make relative paths relative to the input file!)

svelte_paths = {}

for _, input_path in ipairs(input_paths) do

  quarto.log.warning("Looking for Svelte files in " .. input_path)
  local doc = pandoc.read(input_path, "markdown")

  doc:walk {
    Meta = function (meta)

      -- single string: add one path
      if type(m.sverto.use) == "string" then
        svelte_paths:insert(m.sverto.use)
      end

      -- list: add each path
      if pandoc.utils.type(m.sverto.use) ~= "List" then
        for i, svelte_path in ipairs(m.sverto.use) do
            svelte_paths:insert(tostring(svelte_path))
        end
      end

    end
  }
  
end

-- now offset paths and remove duplicates
-- (by assigning values to table keys)
unique_svelte_paths = {}
for _, svelte_path in ipairs(svelte_paths) do
  local offset_path = offset_svelte_path(svelte_path, input_path)
  unique_svelte_paths[offset_path] = offset_path
end

-- now concatenate them with : and send them to the svelte compiler
svelte_path_string = ""
for _, svelte_path in ipairs(unique_svelte_paths) do
  svelte_path_string = svelte_path_string .. svelte_path .. ":"
end

-- finally, call the svelte compiler via rollup
rollup_config = quarto.utils.resolve_path("rollup.config.js")

cmd =
  get_cmd_prefix() ..
  "npm run build " ..
  rollup_config .. " -- " ..
  '--quarto-out-path="' .. os.getenv("QUARTO_PROJECT_OUTPUT_DIR") .. '" ' ..
  '--sverto-in-paths="' .. svelte_path_string .. '"'

local svelteResult = os.execute(cmd)
quarto.log.warning("Svelte compiler finished with code " .. svelteResult)
