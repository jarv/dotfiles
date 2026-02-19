# Omarchy Install Notes

These are my install notes for Omarchy on a Lemur Pro 14" laptop

## Extra packages

### pacman

```
wezterm
zsh
ttf-jetbrains-mono
ruby-stdlib
lsof
yubikey-manager
libfido2
openssh
uv
yt-dlp
ffmpeg
vlc
```

### nordvpn

```
yay -S nordvpn-bin
sudo systemctl enable nordvpnd.service
sudo systemctl start nordvpnd.serviceordvpn-bin
sudo usermod -aG nordvpn $USER
nordvpn login
```

### meshtastic

```
uv tool install meshtastic
sudo usermod -aG uucp,lock $USER
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

## Auto-shutdown after 4h of suspension

Create `/usr/lib/systemd/system-sleep/auto-shutdown-on-long-suspend` (executable, root-owned):

```bash
#!/bin/bash
log() { echo "auto-shutdown-on-long-suspend: $*" | systemd-cat -t auto-shutdown; }
on_ac_power() { grep -q "^status = Charging\|^status = Full\|^online = 1" /sys/class/power_supply/*/uevent 2>/dev/null; }
case "$1" in
  pre)
    if on_ac_power; then
      log "pre suspend: AC power connected, skipping RTC wakeup"
    else
      log "pre suspend: recording time and setting RTC wakeup for 14400s"
      date +%s > /tmp/suspend-time
      rtcwake -m no -s 14400 2>&1 | systemd-cat -t auto-shutdown
      log "pre suspend: done"
    fi
    ;;
  post)
    log "post suspend: woke up"
    if on_ac_power; then
      log "post suspend: AC power connected, skipping shutdown check"
      rm -f /tmp/suspend-time
    elif [ -f /tmp/suspend-time ]; then
      suspended_at=$(cat /tmp/suspend-time)
      now=$(date +%s)
      elapsed=$((now - suspended_at))
      log "post suspend: suspended_at=$suspended_at now=$now elapsed=$elapsed"
      rm /tmp/suspend-time
      if [ "$elapsed" -ge 14400 ]; then
        log "post suspend: elapsed >= 14400s, scheduling poweroff"
        systemd-run --on-active=3 systemctl poweroff
      else
        log "post suspend: elapsed < 14400s, not powering off"
      fi
    else
      log "post suspend: no suspend-time file found"
    fi
    ;;
esac```

```bash
sudo chmod +x /usr/lib/systemd/system-sleep/auto-shutdown-on-long-suspend
```

Scripts in `/usr/lib/systemd/system-sleep/` are called by systemd with `pre`/`post` arguments
on every suspend/resume. `rtcwake -m no -s 14400` programs the hardware RTC to wake the
system after 4h without changing the sleep state. On resume, if ≥4h has elapsed, it
shuts down. If the user wakes the system manually before 4h, nothing happens.
