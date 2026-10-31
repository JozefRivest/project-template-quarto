-- Back-matter parts, styled in backmatter.tex:
--   `# Appendix {.appendix}`                     -> \startappendix{<title>}{<id>}
--   `# Supplementary Materials {.supplementary}` -> \startsupplementary{<title>}{<id>}{<paper title>}
-- Headings inside a part are promoted by one level, so `## Proofs` becomes
-- section A (or S1), `###` becomes A.1 (or S1.1), etc. Any other level-1
-- heading (e.g. `# References`) ends the part.
local function latex(inlines)
  local out = pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines) }), "latex")
  return (out:gsub("%s+$", ""))
end

function Pandoc(doc)
  local in_part = false
  local paper_title = doc.meta.title and latex(doc.meta.title) or ""
  local blocks = pandoc.List()
  for _, block in ipairs(doc.blocks) do
    if block.t == "Header" and block.level == 1 then
      in_part = true
      if block.classes:includes("appendix") then
        blocks:insert(pandoc.RawBlock("latex",
          "\\startappendix{" .. latex(block.content) .. "}{" .. block.identifier .. "}"))
      elseif block.classes:includes("supplementary") then
        blocks:insert(pandoc.RawBlock("latex",
          "\\startsupplementary{" .. latex(block.content) .. "}{" .. block.identifier
          .. "}{" .. paper_title .. "}"))
      else
        in_part = false
        blocks:insert(block)
      end
    else
      if in_part and block.t == "Header" then
        block.level = block.level - 1
      end
      blocks:insert(block)
    end
  end
  doc.blocks = blocks
  return doc
end
