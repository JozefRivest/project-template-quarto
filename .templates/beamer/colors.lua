-- Slide colors from YAML metadata.
--
-- Set any of these in _quarto.yml (applies to the slides and the poster) or in
-- the presentation's YAML header, as quoted hex codes:
--
--   main-color:    "#00274C"  -- fallback for title, header, and text colors
--   title-color:   frame-title bar and title-page title     (default: main)
--   header-color:  navigation bar at the top of each slide  (default: main)
--   text-color:    body text and bullets                    (default: main)
--   accent-color:  "#FFCB05"  -- progress bar, navigation dots
--   alert-color:   "#9A3324"  -- \alert{} text and alert blocks
--   example-color: "#2F65A7"  -- example blocks
--
-- Unset keys keep the University of Michigan defaults of the umich theme.

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
  io.stderr:write("WARNING (colors.lua): ignoring " .. key .. ": '" ..
    pandoc.utils.stringify(value) .. "' (expected a hex code like \"#00274C\")\n")
  return nil
end

function Meta(meta)
  if not FORMAT:match("beamer") then
    return nil
  end

  local main = hex(meta, "main-color")
  local title = hex(meta, "title-color")
  local header = hex(meta, "header-color")
  local text = hex(meta, "text-color")
  local accent = hex(meta, "accent-color")
  local alert = hex(meta, "alert-color")
  local example = hex(meta, "example-color")

  local out = {}
  local function add(line) table.insert(out, line) end

  -- Theme color names: Beamer resolves them when they are used, so redefining
  -- them after the theme is loaded recolors everything that uses them.
  -- mUMBlue drives the text, frame titles, and navigation bar by default.
  if main then add("\\definecolor{mUMBlue}{HTML}{" .. main .. "}") end
  if accent then add("\\definecolor{mUMMaize}{HTML}{" .. accent .. "}") end
  if alert then add("\\definecolor{mUMTappanRed}{HTML}{" .. alert .. "}") end
  if example then add("\\definecolor{mUMArboretumBlue}{HTML}{" .. example .. "}") end

  -- Per-element overrides on top of the main color.
  if text then
    add("\\definecolor{slidetext}{HTML}{" .. text .. "}")
    add("\\setbeamercolor{normal text}{fg=slidetext}")
  end
  if title or text then
    -- Frame titles take their background from the text color in the theme,
    -- so pin them to the title color (or the main color) when text changes.
    local t = title and "slidetitle" or "mUMBlue"
    if title then add("\\definecolor{slidetitle}{HTML}{" .. title .. "}") end
    add("\\setbeamercolor{frametitle}{fg=black!2, bg=" .. t .. "}")
    add("\\setbeamercolor{title}{fg=" .. t .. "}")
  end
  if header then
    add("\\definecolor{slideheader}{HTML}{" .. header .. "}")
    add("\\setbeamercolor{section in head/foot}{bg=slideheader}")
  end

  if #out == 0 then
    return nil
  end

  local block = pandoc.RawBlock("latex", table.concat(out, "\n"))
  local includes = meta["header-includes"]
  if includes == nil then
    includes = pandoc.MetaList({})
  elseif pandoc.utils.type(includes) ~= "List" then
    includes = pandoc.MetaList({ includes })
  end
  includes:insert(pandoc.MetaBlocks({ block }))
  meta["header-includes"] = includes
  return meta
end
