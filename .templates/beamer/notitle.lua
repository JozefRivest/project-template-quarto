-- Slides with the .notitle class keep their place in the navigation but
-- render without a frame title (beamer omits the frametitle bar when empty).
function Header(el)
  if el.classes:includes("notitle") then
    el.content = {}
    return el
  end
end
