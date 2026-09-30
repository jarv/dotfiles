# 06 - Always on, lid closed (final step)

Do this last, once remote access and the LLM server are verified working.
Up to now the machine has behaved like a normal MacBook (sleeps on lid
close); from here on it will not.

A MacBook with the lid closed and no external display normally sleeps.
`pmset disablesleep` is the switch that stops that, no third-party tools
(InsomniaX/Amphetamine) needed.

## Power settings

```sh
# Apply to all power sources (-a). Leave the box on the charger.
sudo pmset -a sleep 0            # never system-sleep
sudo pmset -a disksleep 0        # never spin down/park storage
sudo pmset -a displaysleep 5     # display off after 5 min when one is attached
sudo pmset -a disablesleep 1     # THE key setting: allow lid-closed operation
sudo pmset -a powernap 0         # no periodic wakes needed
sudo pmset -a autorestart 1      # power back on after a power loss
sudo pmset -a womp 1             # wake on magic packet (Ethernet only)
sudo pmset -a hibernatemode 0    # do not write RAM to disk (64GB - slow)
sudo pmset -a standby 0
sudo pmset -a lowpowermode 0     # keep full GPU clocks
sudo pmset -a ttyskeepawake 1    # active ssh session keeps it awake anyway

pmset -g                         # verify
```

Notes:

- `disablesleep 1` also disables the sleep menu item and lid sleep. If you
  ever want to carry the laptop, `sudo pmset -a disablesleep 0` first or the
  battery will drain in your bag.
- Thermals: closed-lid load is fine for an M4 Max, but stand the machine on
  its side or on a vented stand rather than flat on a soft surface. If you
  want to watch it: `sudo powermetrics --samplers smc,gpu_power -i 5000`.
- Battery longevity: macOS "Optimized Battery Charging" holds at 80% when it
  detects an always-plugged pattern; leave it on. There is no CLI toggle for
  it on Tahoe, it is in System Settings > Battery if you want to check.

## Automatic login vs FileVault

With FileVault on, macOS cannot auto-login and needs a password at the
pre-boot unlock screen. Two consequences:

1. **Services must be LaunchDaemons** (system-level, start before login).
   `03-llm-server.md` does exactly that, with `UserName` set to your user so
   models live in `~`.
2. **Remote reboots use `sudo fdesetup authrestart`** which stashes the
   unlock key for exactly one reboot. Never use plain `sudo reboot` remotely
   unless you can reach the keyboard. A crash / power loss will leave the
   machine at the unlock screen until someone types the password - the
   `autorestart 1` above covers the power-loss half but not the unlock.

If you truly cannot accept that and want unattended recovery from power
loss: disable FileVault (`sudo fdesetup disable`) and enable auto-login:

```sh
# only if FileVault is OFF
sudo sysadminctl -autologin set -userName jarv -password -
```

Recommendation: keep FileVault on. A laptop is portable; the models are
public but your SSH/Tailscale keys are not.

## Scheduled reboot (optional)

Weekly reboot to shake out Ollama/MLX memory drift; runs `authrestart` so
FileVault is unlocked automatically:

```sh
sudo cp files/com.local.weekly-authrestart.plist /Library/LaunchDaemons/
sudo launchctl bootstrap system /Library/LaunchDaemons/com.local.weekly-authrestart.plist
```

`authrestart` needs a password for the user unlocking the volume; the plist
in `files/` reads it from `/etc/fde-pass` (mode 0400 root). If you do not
want a password on disk, skip this section and reboot manually.

## Verify

```sh
pmset -g assertions | head      # shows what is keeping it awake
log show --last 1h --predicate 'eventMessage contains "Wake"' | tail
```

Close the lid, wait 10 minutes, and from another machine confirm the box
still answers `ping`/`ssh` (after `02-remote-access.md`).
