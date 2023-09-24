local wz = require 'wezterm'

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
    color_scheme = 'Solarized Dark (Gogh)',
    keys = {
      { key = 'w', mods = 'CMD', action = wz.action.CloseCurrentPane { confirm = false }, },
      { key = 'I', mods = 'CTRL|SHIFT', action = wz.action.SplitHorizontal { domain = 'CurrentPaneDomain' }, },
      { key = 'O', mods = 'CTRL|SHIFT', action = wz.action.SplitVertical { domain = 'CurrentPaneDomain' }, },
      { key = 'Enter', mods = 'CMD', action = wz.action.ToggleFullScreen, },
      { key = 'Enter', mods = 'CMD|SHIFT', action = wz.action.TogglePaneZoomState, },
      { key = '[', mods = 'CTRL|CMD', action = wz.action.ActivateCopyMode, },
      { key = '[', mods = 'CTRL|CMD', action = wz.action.ActivateCopyMode, },
      { key = "h", mods = "CMD", action=wz.action{ActivatePaneDirection="Left"}},
      { key = "j", mods = "CMD", action=wz.action{ActivatePaneDirection="Down"}},
      { key = "k", mods = "CMD", action=wz.action{ActivatePaneDirection="Up"}},
      { key = "l", mods = "CMD", action=wz.action{ActivatePaneDirection="Right"}},
    }
}

return config
