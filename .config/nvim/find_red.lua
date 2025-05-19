-- find_red.lua — quick and dirty highlight red checker
local function hex(n)
  return string.format("#%06x", n)
end

local function find_red_hls()
  local matches = {}
  for _, name in ipairs(vim.fn.getcompletion("", "highlight")) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name })
    if ok then
      for k, v in pairs({ fg = hl.fg, bg = hl.bg }) do
        if v then
          local color = hex(v)
          if color:lower():find("fb4934") or color:lower():find("ff453a") then
            table.insert(matches, string.format("%s.%s = %s", name, k, color))
          end
        end
      end
    end
  end

  if #matches == 0 then
    print("No red highlights found 🚫❤️")
  else
    print("🔥 Red highlights:")
    for _, match in ipairs(matches) do
      print("  " .. match)
    end
  end
end

find_red_hls()
