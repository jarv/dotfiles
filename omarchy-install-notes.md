# Omarchy Install Notes

These are my install notes for Omarchy on a Lemur Pro 14" laptop

## Extra packages

```
wezterm
zsh
ttf-jetbrains-mono
ruby-stdlib
lsof
yubikey-manager
libfido2
openssh
```

## Wezterm

Needs `20241205.083533.6f375e29-1` for Wayland

<https://github.com/wezterm/wezterm/issues/5604>

```
yay -S wezterm-nightly-bin --noconfirm
```

## Hyprland

`~/.config/hypr/monitors.conf`

```
# System76 Lemur Pro 14" - 1920x1200 @ ~148 DPI
# Optimized 1.25x scaling for comfortable readability and good workspace
env = GDK_SCALE,1
monitor = eDP-1, 1920x1200@60, 0x0, 1.25
```

`~/config/hypr/looknfeel.conf`

```
general {
    # No gaps between windows or borders
    gaps_in = 0
    gaps_out = 0
    border_size = 0

    # Use master layout instead of dwindle
    # layout = master
}
```

`~/.config/waybar/config.jsonc`

1. Line 10: Replace "group/tray-expander" with "tray" in the modules-right array
2. Lines 122-137: Delete the entire group/tray-expander and custom/expand-icon

## Firefox

```
xdg-settings set default-web-browser firefox.desktop
```
