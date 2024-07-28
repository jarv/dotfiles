local wz = require 'wezterm'
local act = wz.action
local config = {
  window_close_confirmation = "NeverPrompt",
  check_for_updates = false,

  -- Avoid unexpected config breakage and unusable terminal
  automatically_reload_config = false,

  -- Make sure word selection stops on most punctuations.
  --
  -- Note that dot (.) & slash (/) are allowed though for
  -- easy selection of (partial) paths.
  selection_word_boundary = " \t\n{}[]()\"'`,;:@│┃*",

  -- Disable all noises
  audible_bell = "Disabled",
  window_decorations = "NONE",
  enable_tab_bar = false,
  font = wz.font 'JetBrains Mono',
  font_size = 14.0,
  -- color_scheme = 'Solarized Dark (Gogh)',
  -- color_scheme = 'Rosé Pine (base16)',
  color_scheme = 'Rosé Pine (Gogh)',
  -- disable most font ligatures
  harfbuzz_features = {"calt=0", "clig=0", "liga=0"},
  keys = {
    { key = 'w', mods = 'CMD', action = wz.action.CloseCurrentPane { confirm = false }, },
    { key = 'I', mods = 'CTRL|SHIFT', action = wz.action.SplitHorizontal { domain = 'CurrentPaneDomain' }, },
    { key = 'O', mods = 'CTRL|SHIFT', action = wz.action.SplitVertical { domain = 'CurrentPaneDomain' }, },
    { key = 'Enter', mods = 'CMD', action = wz.action.ToggleFullScreen, },
    { key = 'Enter', mods = 'CMD|SHIFT', action = wz.action.TogglePaneZoomState, },
    { key = '[', mods = 'CTRL|CMD', action = wz.action.ActivateCopyMode, },
    { key = '[', mods = 'CTRL|CMD', action = wz.action.ActivateCopyMode, },
    { key = "h", mods = "ALT", action=wz.action{ActivatePaneDirection="Left"}},
    { key = "j", mods = "ALT", action=wz.action{ActivatePaneDirection="Down"}},
    { key = "k", mods = "ALT", action=wz.action{ActivatePaneDirection="Up"}},
    { key = "l", mods = "ALT", action=wz.action{ActivatePaneDirection="Right"}},
  },
  mouse_bindings = {
    -- Change the default click behavior so that it only selects
    -- text and doesn't open hyperlinks
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = act.CompleteSelection 'ClipboardAndPrimarySelection',
    },

    -- Ctrl-click will open the link under the mouse cursor
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CMD',
      action = wz.action.OpenLinkAtMouseCursor,
    },
  }
}

return config
