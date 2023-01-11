wipeOldRun = {
  Blocks = function(all_blocks) {
    os.remove(".quarto/.svelte-quarto-matches")
  }
}

extractSvelteFiles = {
  CodeBlock = function(el)

    if (el.attr.classes:includes("{ojs}")) then
      local block_contents = el.text
      local svelte_files = {}
      local path_pattern =
        "import%(\"[%w;,/%?:@&=%+%$%-_%.!~%*'%(%)#]+%.svelte\"%)"
        
      -- find import("path/to/file.svelte")
      for extracted_import in string.gmatch(block_contents, path_pattern) do
        local extracted_path =
          string.sub(extracted_import, 9, string.len(extracted_import) - 2)
        table.insert(svelte_files, extracted_path)
      end
      quarto.log.output(svelte_files)

      -- TODO - now cut out duplicates
      -- local sorted_files = table.sort(svelte_files)

      -- TODO - squash path array with \n and write out to disk
      local svelte_file_string = table.concat(svelte_files, "\n")
      io.write()

    else
      -- block is either not ojs or not executable: return empty list
    end
  end
}

-- return {
--   { wipeOldRun = wipeOldRun },
--   { extractSvelteFiles = extractSvelteFiles }
-- }

return {extractSvelteFiles}