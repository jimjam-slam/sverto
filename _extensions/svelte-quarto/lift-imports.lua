-- this is supposed to remove the .svelteimport wrapper from the imports
-- (right now it's just returning it unchanged)
function CodeBlock(el)
  if el.classes:includes("svelteimport") then
    -- return just the content of el
    return el.blocks
  else
    -- return other code blocks unchanged
    return el
  end
end