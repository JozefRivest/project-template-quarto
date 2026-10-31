-- With cite-method: biblatex, pandoc ignores the :::{#refs} div. Print the
-- bibliography there; the heading comes from the surrounding markdown.
function Div(el)
  if el.identifier == "refs" and FORMAT:match("latex") then
    return pandoc.RawBlock("latex", "\\printbibliography[heading=none]")
  end
end
