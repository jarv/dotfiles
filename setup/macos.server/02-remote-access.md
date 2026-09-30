# 02 - Remote access: Tailscale + SSH

Model: **nothing is reachable from LAN or Internet**. Everything goes over the
tailnet. SSH accepts keys only.

## Tailscale (brew formula = open-source `tailscaled`)

The App Store / `.app` version cannot do `tailscale serve` or Tailscale SSH on
macOS; the brew formula can, and it runs as a root LaunchDaemon so it is up
before login.

```sh
brew install tailscale          # already in setup/macos.server/Brewfile
sudo brew services start tailscale
sudo tailscale up --ssh --hostname llmbox --accept-dns
```

`tailscale up` prints an auth URL; open it on any device. Then in the
[admin console](https://login.tailscale.com/admin):

- **DNS > MagicDNS**: on. **HTTPS Certificates**: on (needed by `tailscale serve`).
- Disable key expiry for `llmbox` (Machines > ... > Disable key expiry) so it
  does not fall off the tailnet after 180 days.
- Optionally add an ACL so only your own devices can reach `llmbox:22,443`.

Check:

```sh
tailscale status
tailscale ip -4                 # 100.x.y.z
```

## SSH server

```sh
sudo systemsetup -setremotelogin on
sudo systemsetup -getremotelogin        # Remote Login: On
```

Harden it. Tahoe's `sshd_config` includes `/etc/ssh/sshd_config.d/*`, so
drop a file in there rather than editing the main config:

```sh
sudo cp files/sshd-hardening.conf /etc/ssh/sshd_config.d/10-hardening.conf
sudo sshd -t && sudo launchctl kickstart -k system/com.openssh.sshd
```

`files/sshd-hardening.conf` does:

```
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
AllowUsers jarv
ClientAliveInterval 60
ClientAliveCountMax 3
X11Forwarding no
# Only listen on loopback + the tailnet. Uncomment after tailscale is up:
# ListenAddress 127.0.0.1
# ListenAddress 100.x.y.z
```

Put your public key in place **before** restarting sshd with passwords off:

```sh
mkdir -p ~/.ssh && chmod 700 ~/.ssh
# from your client:  ssh-copy-id jarv@llmbox   (works once, while passwords are still on)
chmod 600 ~/.ssh/authorized_keys
```

Prefer `ListenAddress` restriction over the macOS firewall: the built-in
application firewall (`socketfilterfw`) is per-app, not per-port/interface,
and `sshd` is Apple-signed so it will be allowed regardless. If you want a
hard interface rule use `pf` (see below).

### Tailscale SSH (alternative/complement)

`--ssh` above lets Tailscale itself authenticate SSH using your tailnet
identity - no keys to manage, and access is governed by ACLs. Both can coexist;
Tailscale SSH intercepts port 22 on the tailscale interface only. If you rely
solely on Tailscale SSH you can set `ListenAddress 127.0.0.1` in sshd and be
done.

## Firewall

```sh
# Application firewall: on, stealth, block all inbound except signed services
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setblockall off
```

Optional `pf` rule set that drops everything on the physical interfaces except
what Tailscale needs (UDP 41641) and allows all on `utun*`:

```sh
sudo cp files/pf-llmbox.conf /etc/pf.anchors/llmbox
# add to /etc/pf.conf:   anchor "llmbox" \n load anchor "llmbox" from "/etc/pf.anchors/llmbox"
sudo pfctl -f /etc/pf.conf && sudo pfctl -e
```

Skip `pf` if you are comfortable with "services bind to 127.0.0.1 and only
`tailscale serve` exposes them"; that alone already means the LAN sees nothing
but sshd (and sshd only if you left its ListenAddress open).

## Other machines

`dotfile.ssh.config` already has the `Host llmbox` stanza (MagicDNS name,
`User jarv`, `ForwardAgent no`) and the YubiKey PKCS11 provider, so on a
workstation with the dotfiles symlinked `ssh llmbox` just works. The key
offered will be the YubiKey PIV key once it is loaded:

```sh
ssh-add -s /usr/lib/ssh-keychain.dylib     # once per boot on the workstation
ssh-add -L                                 # copy this pubkey into llmbox:~/.ssh/authorized_keys
```

`mosh llmbox` also works over the tailnet (mosh is in `setup/macos.server/Brewfile`) and
survives laptop sleep on the client side.

## Remote reboot

```sh
ssh llmbox 'sudo fdesetup authrestart'
```

You will be prompted for the FileVault user password over the ssh session.
Give it ~60s and `tailscale status` should show it back.

## Verify from a client

```sh
tailscale ping llmbox
ssh llmbox uptime
nmap -Pn llmbox-lan-ip           # from LAN: should show 22 only (or nothing)
```
