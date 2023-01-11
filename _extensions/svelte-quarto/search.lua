SvelteSearchFilter = {

  CodeBlock = function(el)
    print("CODEBLOCK:")
    local quarto_match_path = ".quarto/.svelte-quarto-matches"
  
    if (el.attr.classes:includes("js") and
      el.attr.classes:includes("cell-code")) then
      
      local block_contents = el.text
      local svelte_files = {}
      local path_pattern =
        "import%(\"[%w;,/%?:@&=%+%$%-_%.!~%*'%(%)#]+%.svelte\"%)"
        
      -- find import("path/to/file.svelte")
      -- TODO - just substitute .svelte for .js right now!
      for extracted_import in string.gmatch(block_contents, path_pattern) do
        local extracted_path =
          string.sub(extracted_import, 9, string.len(extracted_import) - 2)
        print("Found path...")
        print(extracted_path)
        table.insert(svelte_files, extracted_path)
      end
  
      -- TODO - cut out duplicates?
      -- local sorted_files = table.sort(svelte_files)
  
      -- write svelte files out to disk
      if #svelte_files > 0 then
        print("Num. files to output: " .. tostring(#svelte_files))
        print("Outputting Svelte files...")
        quarto.log.output(svelte_files)

        local svelte_file_string = table.concat(svelte_files, "\n")
        local quarto_match_file = io.open(quarto_match_path, "a")
        io.output(quarto_match_file):write(svelte_file_string .. "\n")
        io.close(quarto_match_file)
      else
        print("No paths found in this block")
      end
  
    else
      -- block is either not ojs or not executable: return empty list
    end
  end
}

return { SvelteSearchFilter }
