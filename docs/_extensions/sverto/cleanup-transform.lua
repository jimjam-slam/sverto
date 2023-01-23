-- replaces the doc body with just its first block (assumed to be the
-- version of the doc with transformed .svelte -> .js refs)
Pandoc = function(doc)
  doc.blocks = doc.blocks[1].content
  return doc
end
