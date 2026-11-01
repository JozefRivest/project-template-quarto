-- Poster layout filter.
--
-- Turns author-friendly markdown into beamerposter LaTeX:
--
--   ::: column          -> \separatorcolumn \begin{column}{\colwidth} ... \end{column}
--   ## Heading          -> \begin{block}{Heading} ... \end{block}
--   ## Heading {.alert}  -> \begin{alertblock}{Heading} ... \end{alertblock}
--   ## Heading {.example}-> \begin{exampleblock}{Heading} ... \end{exampleblock}
--   ### Sub-heading      -> \heading{Sub-heading}   (inside a block)
--
-- Content before the first `##` inside a column is emitted as-is.

local function raw(s)
  return pandoc.RawBlock("latex", s)
end

local function block_env(header)
  if header.classes:includes("alert") then
    return "alertblock"
  elseif header.classes:includes("example") then
    return "exampleblock"
  else
    return "block"
  end
end

function Div(el)
  if not el.classes:includes("column") then
    return nil
  end

  local out = pandoc.List:new()
  out:insert(raw("\\separatorcolumn"))
  out:insert(raw("\\begin{column}{\\colwidth}"))

  local cur_title = nil
  local cur_env = nil
  local cur_body = pandoc.List:new()

  local function flush()
    if cur_title ~= nil then
      out:insert(raw("\\begin{" .. cur_env .. "}{" .. cur_title .. "}"))
    end
    for _, b in ipairs(cur_body) do
      out:insert(b)
    end
    if cur_title ~= nil then
      out:insert(raw("\\end{" .. cur_env .. "}"))
    end
    cur_title = nil
    cur_env = nil
    cur_body = pandoc.List:new()
  end

  for _, b in ipairs(el.content) do
    if b.t == "Header" and b.level == 2 then
      flush()
      cur_title = pandoc.utils.stringify(b.content)
      cur_env = block_env(b)
    elseif b.t == "Header" and b.level >= 3 then
      cur_body:insert(raw("\\heading{" .. pandoc.utils.stringify(b.content) .. "}"))
    else
      cur_body:insert(b)
    end
  end
  flush()

  out:insert(raw("\\end{column}"))
  return out
end

-- "#7a0019" or "7A0019" -> "7A0019"; anything else -> nil (with a warning).
local function hex(meta, key)
  local value = meta[key]
  if value == nil then
    return nil
  end
  local s = pandoc.utils.stringify(value):gsub("^%s*#?", ""):gsub("%s*$", "")
  if s:match("^%x%x%x%x%x%x$") then
    return s:upper()
  end
  io.stderr:write("WARNING (poster.lua): ignoring " .. key .. ": '" ..
    pandoc.utils.stringify(value) .. "' (expected a hex code like \"#00274C\")\n")
  return nil
end

-- Poster colors from YAML (quoted hex codes):
--   main-color:   header, footer, block titles, and bullets
--   title-color:  block titles              (default: main-color)
--   header-color: header and footer band    (default: main-color)
--   text-color:   body text                 (default: black)
--   accent-color: line under block titles   (default: black)
local function poster_colors(meta)
  local main = hex(meta, "main-color")
  local title = hex(meta, "title-color")
  local header = hex(meta, "header-color")
  local text = hex(meta, "text-color")
  local accent = hex(meta, "accent-color")

  local out = {}
  local function add(line) table.insert(out, line) end

  -- umichblue drives the header, footer, block titles, and bullets.
  if main then add("\\definecolor{umichblue}{HTML}{" .. main .. "}") end
  if title then
    add("\\definecolor{postertitle}{HTML}{" .. title .. "}")
    for _, b in ipairs({ "block title", "block alerted title", "block example title" }) do
      add("\\setbeamercolor{" .. b .. "}{fg=postertitle}")
    end
  end
  if header then
    add("\\definecolor{posterheader}{HTML}{" .. header .. "}")
    add("\\setbeamercolor{headline}{bg=posterheader}")
  end
  if text then
    add("\\definecolor{postertext}{HTML}{" .. text .. "}")
    for _, b in ipairs({ "normal text", "block body", "block alerted body",
                         "block example body", "heading" }) do
      add("\\setbeamercolor{" .. b .. "}{fg=postertext}")
    end
  end
  if accent then
    add("\\definecolor{posteraccent}{HTML}{" .. accent .. "}")
    for _, b in ipairs({ "block separator", "block alerted separator",
                         "block example separator" }) do
      add("\\setbeamercolor{" .. b .. "}{bg=posteraccent}")
    end
  end
  return out
end

-- Pass logo settings to the template as raw LaTeX, so a path such as
-- `logos/my_logo.png` is not escaped (`my\_logo.png`) by pandoc, and build
-- the color definitions for the template's `poster-colors` slot.
function Meta(meta)
  for _, key in ipairs({ "logo", "logo-height" }) do
    if meta[key] ~= nil then
      meta[key] = pandoc.RawInline("latex", pandoc.utils.stringify(meta[key]))
    end
  end
  local colors = poster_colors(meta)
  if #colors > 0 then
    meta["poster-colors"] = pandoc.MetaBlocks({
      pandoc.RawBlock("latex", table.concat(colors, "\n"))
    })
  end
  return meta
end
