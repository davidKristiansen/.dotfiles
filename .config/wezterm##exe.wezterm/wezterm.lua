local wezterm = require 'wezterm'
local action = wezterm.action
local config = wezterm.config_builder()

wezterm.on('update-right-status', function(window, pane)
  local name = window:active_key_table()
  if name then
    name = 'TABLE: ' .. name
  end
  window:set_right_status(name or '')
end)

-- This is where you actually apply your config choices

config.color_scheme = 'Gruvbox dark, hard (base16)'
config.font = wezterm.font 'CaskaydiaCove Nerd Font Mono'
config.animation_fps = 10
config.hide_tab_bar_if_only_one_tab = true


config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }
-- config.keys = {
--   { key = 'l', mods = 'ALT|SHIFT', action = wezterm.action.ShowLauncher },
--   {
--     key = '%',
--     mods = 'LEADER|SHIFT',
--     action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }
--   },
--   {
--     key = '"',
--     mods = 'LEADER|SHIFT',
--     action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }
--   },
--   {
--     key = 'r',
--     mods = 'LEADER',
--     action = action.ActivateKeyTable {
--       name = 'resize_pane',
--       one_shot = false,
--     },
--   },
-- }

-- for i = 1, 9 do
--   table.insert(config.keys, {
--     key = tostring(i),
--     mods = 'ALT',
--     action = action.ActivateTab(i - 1),
--
--   })
-- end

-- config.key_tables = {
--   -- Defines the keys that are active in our resize-pane mode.
--   -- Since we're likely to want to make multiple adjustments,
--   -- we made the activation one_shot=false. We therefore need
--   -- to define a key assignment for getting out of this mode.
--   -- 'resize_pane' here corresponds to the name="resize_pane" in
--   -- the key assignments above.
--   resize_pane = {
--     { key = 'LeftArrow',  action = action.AdjustPaneSize { 'Left', 1 } },
--     { key = 'h',          action = action.AdjustPaneSize { 'Left', 1 } },
--     { key = 'RightArrow', action = action.AdjustPaneSize { 'Right', 1 } },
--     { key = 'l',          action = action.AdjustPaneSize { 'Right', 1 } },
--     { key = 'UpArrow',    action = action.AdjustPaneSize { 'Up', 1 } },
--     { key = 'k',          action = action.AdjustPaneSize { 'Up', 1 } },
--     { key = 'DownArrow',  action = action.AdjustPaneSize { 'Down', 1 } },
--     { key = 'j',          action = action.AdjustPaneSize { 'Down', 1 } },
--     { key = 'LeftArrow',  action = action.AdjustPaneSize { 'Left', 10 },  mods = 'SHIFT', },
--     { key = 'h',          action = action.AdjustPaneSize { 'Left', 10 },  mods = 'SHIFT', },
--     { key = 'RightArrow', action = action.AdjustPaneSize { 'Right', 10 }, mods = 'SHIFT', },
--     { key = 'l',          action = action.AdjustPaneSize { 'Right', 10 }, mods = 'SHIFT', },
--     { key = 'UpArrow',    action = action.AdjustPaneSize { 'Up', 10 },    mods = 'SHIFT' },
--     { key = 'k',          action = action.AdjustPaneSize { 'Up', 10 },    mods = 'SHIFT' },
--     { key = 'DownArrow',  action = action.AdjustPaneSize { 'Down', 10 },  mods = 'SHIFT', },
--     { key = 'j',          action = action.AdjustPaneSize { 'Down', 10 },  mods = 'SHIFT', },
--     { key = 'Escape',     action = 'PopKeyTable' },
--   },
--
--   -- Defines the keys that are active in our activate-pane mode.
--   -- 'activate_pane' here corresponds to the name="activate_pane" in
--   -- the key assignments above.
-- }

config.unix_domains = {
  {
     name = "e14ec05ade14",
     proxy_command = {"docker", "exec", "-i", "e14ec05ade14", "wezterm", "cli", "proxy"}
   }
}


wezterm.plugin
    .require('https://github.com/mrjones2014/smart-splits.nvim')
    .apply_to_config(config)

wezterm.plugin
    .require("https://github.com/nekowinston/wezterm.bar")
    .apply_to_config(config, {
      position = "bottom",
      dividers = false,
      indicator = {
        leader = {
          enabled = true,
          off = " ",
          on = " ",
        },
        mode = {
          enabled = true,
          names = {
            resize_mode = "RESIZE",
            copy_mode = "VISUAL",
            search_mode = "SEARCH",
          },
        },
      }
    })

return config
