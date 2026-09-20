<div align="center">

<img src="https://raw.githubusercontent.com/NixOS/nixos-artwork/master/logo/nix-snowflake-colours.svg" alt="NixOS" width="120" height="120" />

# My NixOS Configuration &amp; Backup

**A declaratively-configured NixOS workstation, with a self-syncing, secret-scanned, off-machine dotfile backup.**

[![NixOS](https://img.shields.io/badge/NixOS-unstable-5277C3?style=flat-square&logo=nixos&logoColor=white)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-flakes-5277C3?style=flat-square)](https://wiki.nixos.org/wiki/Flakes)
[![Hyprland](https://img.shields.io/badge/Wayland-Hyprland-58E1FF?style=flat-square)](https://hyprland.org)
[![Shell](https://img.shields.io/badge/shell-fish-34C534?style=flat-square)](https://fishshell.com)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](#license)

</div>

---

## A note before you use this

**This is my personal system.** Every choice in this repository — the CachyOS kernel, Hyprland, DMS shell, the specific packages, the file layout, the backup paths — reflects how **I** like my machine. It is not a general-purpose NixOS starter, and it is not opinionated about what *you* should run.

That means two things:

1. If you're cloning this to see what NixOS can look like, or to steal ideas, **feel free to delete anything you don't want**. Strip out `configuration.nix` sections you don't need, remove packages from the list, replace Hyprland with your compositor of choice. The flake is a starting point, not a contract.
2. If you want exactly what I have, keep it as-is. You'll get an Intel-graphics Hyprland workstation running a CachyOS `-v3` kernel with Steam, Waydroid, Tailscale, Samba, and a set of dotfiles I use daily. Just know that some of it is tuned to my hardware.

I've written the rest of this README as if you (or future-me on a fresh machine) are setting it up from scratch. Follow it in order.

---

## Prerequisites

**Read this before you do anything else.** The backup script cannot run until these are done, and the rebuild cannot run until at least step 3 is done.

### 1. A working NixOS install

You need a machine already running NixOS — either the one you're migrating *from*, or a fresh minimal install you're migrating *to*. This repository does not bootstrap the OS. It assumes:

- NixOS is already installed and boots.
- `nixos-rebuild`, `nix`, and `git` are on your `$PATH`. On a minimal install you may need to add `git` temporarily:
  ```fish
  nix-shell -p git
  ```
- You have `sudo` access (i.e. you're in the `wheel` group).

If you're restoring on a brand-new machine, do a plain NixOS install first, set the hostname to `nixos` (matching the flake), then come back here.

### 2. Create your own GitHub repository

Do **not** push to mine. Create your own empty repository:

1. Go to <https://github.com/new>.
2. Name it whatever you want. I called mine `NixOS`.
3. Make it **Private**. You're going to be pushing configuration files, dotfiles, and the flake — even with the secret scan, private is the responsible default.
4. **Do not** initialise it with a README, `.gitignore`, or license. You want it empty so the first push succeeds cleanly.
5. Copy the SSH URL. It looks like `git@github.com:<your-username>/<your-repo>.git`.

Throughout this README, replace `git@github.com:LadyHawk2006/NixOS.git` with your own repository URL.

### 3. Configure your Git identity

Git will refuse to commit without a name and email. Set them once, globally:

```fish
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

Use the **same email** you registered your GitHub account with, otherwise commits won't be attributed to you.

### 4. Generate an SSH key and add it to GitHub

GitHub over HTTPS will prompt for a password (which no longer works) or a personal access token (which is tedious). SSH keys are the sane option. If you already have a key, skip to the "add to GitHub" step.

**Generate a key** (ed25519 is the modern default; do not use RSA):

```fish
ssh-keygen -t ed25519 -C "you@example.com"
```

When prompted:

- Press **Enter** to accept the default path (`~/.ssh/id_ed25519`).
- Enter a passphrase if you want one. I recommend yes. If you set one, make sure `ssh-agent` is running (see below) so you don't type it on every push.

**Start the SSH agent and add the key**:

```fish
eval (ssh-agent -c)
ssh-add ~/.ssh/id_ed25519
```

To make this happen automatically on every login, add the `ssh-agent` invocation to your fish config (`~/.config/fish/config.fish`).

**Copy the public key**:

```fish
cat ~/.ssh/id_ed25519.pub
```

**Add it to GitHub**:

1. Go to <https://github.com/settings/keys>.
2. Click **New SSH key**.
3. Give it a title (e.g. the hostname of this machine).
4. Paste the entire output of the `cat` command — starting with `ssh-ed25519` and ending with your email.
5. Save.

### 5. Verify GitHub access

Before you go any further, prove that the key works:

```fish
ssh -T git@github.com
```

You should see something like:

```
Hi <username>! You've successfully authenticated, but GitHub does not provide shell access.
```

If you see `Permission denied (publickey)`, stop and fix this. Every push in the rest of this README depends on it. Common causes:

- The key wasn't added to `ssh-agent`: run `ssh-add ~/.ssh/id_ed25519` again.
- You pasted the **private** key (the file *without* `.pub`) into GitHub. Paste the `.pub` one.
- You have an old key in `~/.ssh/config` pointing `github.com` somewhere else.

### 6. (Optional) Install gitleaks

The backup script scans staged changes for secrets before committing. If `gitleaks` is not installed, the scan is skipped with a warning.

You have two options:

- **Skip it for now.** The script won't fail. Install it later.
- **Install it via this flake's config.** It's already in `environment.systemPackages` in `configuration.nix`, so a rebuild picks it up. Or install it ad-hoc:
  ```fish
  nix profile install nixpkgs#gitleaks
  ```

---

## Linking `/etc/nixos` to `~/.config/nixos`

By default NixOS expects the flake at `/etc/nixos`, which is **owned by root**. That means every time you want to edit `configuration.nix`, you have to do it through `sudo nano` or similar. I do not want to edit my NixOS config as root — I want to use Zed, VS Code, or whatever editor I feel like, with my own keybindings and my own user permissions.

The fix is to move `/etc/nixos` into my home directory and leave a symlink behind. NixOS will still find it (because `/etc/nixos` resolves through the symlink), and I get to edit the files as my normal user.

**Run these three commands exactly once, on a machine that already has `/etc/nixos`**:

```fish
sudo mv /etc/nixos ~/.config/nixos
sudo chown -R $USER:users ~/.config/nixos
sudo ln -s ~/.config/nixos /etc/nixos
```

What each command does:

| Command | What it does |
|---|---|
| `sudo mv /etc/nixos ~/.config/nixos` | Moves the flake out of `/etc` and into your home directory. |
| `sudo chown -R $USER:users ~/.config/nixos` | Hands ownership to you, so you can edit without `sudo`. |
| `sudo ln -s ~/.config/nixos /etc/nixos` | Leaves a symlink behind so `nixos-rebuild` (and any tool expecting `/etc/nixos`) still finds it. |

Verify it worked:

```fish
ls -la /etc/nixos
# Should print: /etc/nixos -> /home/<you>/.config/nixos

ls ~/.config/nixos
# Should list: configuration.nix  flake.lock  flake.nix  hardware-configuration.nix
```

From this point on, **`~/.config/nixos` is the canonical path** and `/etc/nixos` is just a compatibility symlink. Every command in the rest of this README uses `~/.config/nixos`.

> **Note for readers on a fresh install:** if you're setting up on a brand-new machine, run these commands *after* you've installed NixOS but *before* you clone this repository, so the cloned files land in the right place. Or clone first, then copy the files into `~/.config/nixos` and symlink. Both work.

---

## What this repository is

This GitHub repository is the **off-machine backup** of my NixOS configuration and the dotfiles I care about. Everything in it is put there automatically by a single script, `rebuild-sync`, which I run whenever I change something.

The repository serves **two purposes at once**:

1. **It is the backup.** Every time I run the script, it snapshots my flake, my fish config, my Hyprland config, my MPV config, and my `~/.local/bin/` into this repo, commits, and pushes. If my SSD dies tomorrow, I lose nothing important.
2. **It is the source of truth for restore.** On a fresh machine, I clone this repo, run a handful of copy commands to put things back where they belong, and I'm home.

The flake itself — `configuration.nix`, `flake.nix`, `hardware-configuration.nix` — lives at `~/.config/nixos` (symlinked from `/etc/nixos`), which is *also* a Git repository in its own right. The backup repo captures a *copy* of that flake under the `nixos/` subdirectory, but strips out `.git/` so the two histories stay separate. That's why you'll see `nixos/` inside this repo without its own Git metadata.

---

## Repository layout

Cloning this repository gives you exactly this:

```
NixOS/                           # The backup repo root
├── README.md                    # This file
├── config/                      # Mirrors of ~/.config/
│   ├── fish/                    # Fish shell: config.fish, functions, completions
│   ├── hypr/                    # Hyprland: hyprland.lua + dms/ config tree
│   └── mpv/                     # MPV: mpv.conf, input.conf, scripts, fonts
├── local/
│   └── bin/                     # Mirrors of ~/.local/bin/
│       ├── chorus               # A small GTK app I wrote
│       ├── data/                # Its source assets (icons, po, screenshots)
│       ├── rebuild-sync         # The backup script itself
│       └── remux.py             # A video remux helper
└── nixos/                       # Mirror of ~/.config/nixos/ (minus .git/)
    ├── configuration.nix
    ├── flake.lock
    ├── flake.nix
    └── hardware-configuration.nix
```

Everything is laid out to mirror the **original absolute paths** with `~` replaced by the repo root. So `~/NixOS/config/fish/config.fish` corresponds to `~/.config/fish/config.fish`. That one-to-one mapping is what makes restore a series of simple `cp -a` commands.

The backup script lives at `local/bin/rebuild-sync` inside this repo, and it backs itself up — so it survives any restore.

---

## The `rebuild-sync` script

`rebuild-sync` is the only thing you need to remember. It's a Fish script that does five things in strict order, and stops the moment any of them fails.

### What it does

1. **Rebuilds NixOS.** Runs `nixos-rebuild switch` against `~/.config/nixos`. If the rebuild fails, nothing else runs and no backup is made. This is deliberate: a snapshot taken after a broken rebuild is worse than no snapshot.
2. **Rsyncs the dotfiles.** Copies `~/.config/{fish,hypr,mpv}`, `~/.local/bin`, and `~/.config/nixos` into the backup repo, using `--delete-after` so that files you removed from source disappear from the backup on the next run, and `--backup --backup-dir` so that anything overwritten or deleted is preserved in a timestamped trash directory first.
3. **Scans for secrets.** Runs `gitleaks` against the exact staged diff — i.e. the exact contents of the next commit. If it finds anything that looks like an API key, password, or token, the script aborts and nothing is committed.
4. **Commits.** If there are changes, commits them with a structured message containing the hostname, NixOS version, timestamp, and file count.
5. **Pulls, rebases, and pushes.** Rebases onto the remote, then pushes with up to three retries and exponential backoff. If all retries fail, it writes a `.push_pending` marker and leaves the commit local — the next run will retry.

### How it avoids running twice at once

At startup, the script uses `flock` to grab an exclusive lock on `~/.sysbackup/.lock`. If another instance is already running, it exits immediately. The lock is released automatically by the kernel when the process dies, even on `SIGKILL`, so there is no such thing as a stale lock.

### Where it puts things

| Path | What it is |
|---|---|
| `~/.sysbackup/` | The backup repo. This is what gets pushed to GitHub. |
| `~/.sysbackup/backup.log` | Append-only log of every run. Tracked by Git, so you get history. |
| `~/.sysbackup/.trash/YYYYMMDD-HHMMSS-XXXXXX/` | Per-run trash for anything the rsync overwrote or deleted. Gitignored. |
| `~/.sysbackup/.push_pending` | Marker written when a push fails. Gitignored. |

### Invoking it

I have a fish function called `nixbuild` that wraps the script so I can just type `nixbuild` from anywhere. If you don't want to set that up, run the script directly:

```fish
~/.local/bin/rebuild-sync
```

There is also a `nixupdate` fish function, which does `nix flake update` in `~/.config/nixos` and then calls `nixbuild`. Use it when you want to pull in updates from upstream.

---

## What gets backed up

Exactly these paths, and nothing else:

| In the backup | From the live system |
|---|---|
| `config/fish/` | `~/.config/fish/` |
| `config/hypr/` | `~/.config/hypr/` |
| `config/mpv/` | `~/.config/mpv/` |
| `local/bin/` | `~/.local/bin/` |
| `nixos/` | `~/.config/nixos/` (with `.git/` excluded) |
| `backup.log` | Generated by the script |

Deliberately **excluded**:

- `~/.ssh/`, `~/.gnupg/`, `~/.config/sops/` — private keys, by design.
- `~/.cache/`, `~/.local/share/`, `~/.local/state/` — regenerable state.
- The Nix store — that's Nix's job, via the flake.
- `.direnv/`, `result` — build artifacts.

If you want to back up a path I haven't included, edit the `syncs` list inside `local/bin/rebuild-sync` and add it. The list is a flat sequence of source–destination pairs, so adding an entry is a two-line diff.

---

## Setting up on a machine you own

This is the sequence I ran on the machine that would *become* the pusher. Do this after [Prerequisites](#prerequisites) and after you've [symlinked `/etc/nixos`](#linking-etcnixos-to-confignixos).

### 1. Clone this repository into `~/.sysbackup`

I keep the backup repo at `~/.sysbackup` because that's what the script expects. Clone yours there:

```fish
git clone git@github.com:LadyHawk2006/NixOS.git ~/.sysbackup
```

Replace the URL with your own repo if you forked this.

### 2. Make sure your `~/.config/nixos` matches the flake in the backup

If you're on a machine that already has its own `~/.config/nixos`, compare it against `~/.sysbackup/nixos/`. They should be near-identical. If your local flake is authoritative, just leave it — the next `rebuild-sync` run will overwrite the backup with your version.

If you're on a machine whose flake is empty or wrong and you want the backup's version:

```fish
cp -a ~/.sysbackup/nixos/. ~/.config/nixos/
```

### 3. Restore the dotfiles (only if the machine is empty)

Skip this if you're on your usual machine and just want the backup to start working.

```fish
cp -a ~/.sysbackup/config/fish ~/.config/
cp -a ~/.sysbackup/config/hypr ~/.config/
cp -a ~/.sysbackup/config/mpv  ~/.config/
cp -a ~/.sysbackup/local/bin/. ~/.local/bin/
chmod +x ~/.local/bin/rebuild-sync
```

### 4. Run it

```fish
~/.local/bin/rebuild-sync
```

The first run will probably report a small number of changes, commit them, and push. If it's the very first push to a brand-new repository, expect a single large commit.

---

## Restoring on a brand-new machine

This is the section you read when your old laptop is in a thousand pieces and you're staring at a freshly-installed NixOS with nothing but a terminal and a network cable. Take it slowly; it's not hard, but every step matters.

### Step 1 — Install NixOS

Do a plain install. The graphical installer or the terminal installer, whichever you prefer. Minimum viable state:

- NixOS boots to a usable shell.
- You have a user account in the `wheel` group.
- You have network.

Set the hostname to **`nixos`** during install, or plan to pass `--flake ...#nixos` explicitly on every rebuild. The flake defines exactly one host called `nixos`; if your running hostname is something else, `nixos-rebuild` will refuse to find it.

### Step 2 — Prepare the minimum tooling

You need `git` and `openssh`. On a minimal install, drop into a temp shell:

```fish
nix-shell -p git openssh
```

On a full install they're already present.

### Step 3 — Configure Git and GitHub

Redo [Prerequisites 3, 4, and 5](#3-configure-your-git-identity) on this new machine. You need:

- `git config --global user.name` and `user.email` set.
- A fresh SSH key generated (`ssh-keygen -t ed25519 -C "you@example.com"`) — you do **not** want to reuse the old one, since the whole point of a fresh machine is starting fresh keys.
- The public key added to your GitHub account at <https://github.com/settings/keys>.
- `ssh -T git@github.com` returns `Hi <you>!`.

If the old machine is still accessible, you could copy `~/.ssh/id_ed25519` and `id_ed25519.pub` over instead. I prefer not to — a new machine should have its own keys, so you can revoke individual keys if a single machine is compromised.

### Step 4 — Clone the backup repository

```fish
git clone git@github.com:LadyHawk2006/NixOS.git ~/.sysbackup
```

If the machine's disk is small and you don't want the full backup history yet, you can shallow-clone:

```fish
git clone --depth 1 git@github.com:LadyHawk2006/NixOS.git ~/.sysbackup
```

You can always `git fetch --unshallow` later.

### Step 5 — Reconstruct `~/.config/nixos` and symlink `/etc/nixos`

The backup contains the flake under `~/.sysbackup/nixos/`. We want it at `~/.config/nixos` with `/etc/nixos` symlinked to it.

First, check what's currently at `/etc/nixos`:

```fish
ls -la /etc/nixos
```

If the installer put files there, move them aside (do not delete — you might want to diff them later):

```fish
sudo mv /etc/nixos /etc/nixos.installer-backup
```

Now create `~/.config/nixos` and copy the flake in:

```fish
mkdir -p ~/.config/nixos
cp -a ~/.sysbackup/nixos/. ~/.config/nixos/
```

Verify the contents:

```fish
ls ~/.config/nixos
# Should list: configuration.nix  flake.lock  flake.nix  hardware-configuration.nix
```

Now symlink:

```fish
sudo ln -s ~/.config/nixos /etc/nixos
```

Confirm:

```fish
ls -la /etc/nixos
# Should print: /etc/nixos -> /home/<you>/.config/nixos
```

### Step 6 — Reconstruct the dotfiles

Now the important part. The backup stores files at their original **relative** paths, so restoration is a series of `cp -a` commands. The `-a` flag preserves permissions, timestamps, and symlinks — do not omit it.

**Fish shell** — restore `~/.config/fish`:

```fish
mkdir -p ~/.config
cp -a ~/.sysbackup/config/fish ~/.config/
```

This brings back `config.fish`, `fish_variables`, and the `functions/` and `completions/` subdirectories. Note that `fish_variables` contains some shell state — you may want to inspect it before overwriting an existing one.

**Hyprland** — restore `~/.config/hypr`:

```fish
cp -a ~/.sysbackup/config/hypr ~/.config/
```

This brings back `hyprland.lua` and the `dms/` subdirectory with all the module configs (binds, colors, layout, cursor, outputs, windowrules, etc.).

**MPV** — restore `~/.config/mpv`:

```fish
cp -a ~/.sysbackup/config/mpv ~/.config/
```

This brings back `mpv.conf`, `input.conf`, the `scripts/` folder (containing `modernz.lua`), and the `fonts/` folder (`modernz-icons.ttf`).

**Personal binaries and scripts** — restore `~/.local/bin`:

```fish
mkdir -p ~/.local
cp -a ~/.sysbackup/local/bin/. ~/.local/bin/
```

Notice the `.` at the end of the source — `local/bin/.` means "the *contents* of `local/bin`", which is what you want. Without it, `cp -a source dest` would create `~/.local/bin/bin/` if `~/.local/bin` already existed.

After copying, make sure the executables are, well, executable:

```fish
chmod +x ~/.local/bin/*
```

And specifically confirm the backup script is runnable:

```fish
chmod +x ~/.local/bin/rebuild-sync
~/.local/bin/rebuild-sync --help 2>/dev/null || echo "script is not a --help script, that's fine"
```

The second command is just a smoke test; it will print an error about `--help` if the script isn't set up to accept it, which is expected.

### Step 7 — Verify the flake is intact

Before rebuilding, make sure the flake evaluates cleanly:

```fish
cd ~/.config/nixos
nix flake check
nix eval .#nixosConfigurations --apply builtins.attrNames
```

The second command should print `[ "nixos" ]`. If it prints a different name, the flake's hostname doesn't match your expectation — check `flake.nix`.

### Step 8 — Deal with `hardware-configuration.nix`

The backup contains the `hardware-configuration.nix` from **my** machine. That file contains disk UUIDs, kernel modules for my specific hardware, and possibly filesystem definitions that will not match yours. If you build with it, the rebuild will very likely succeed but the system may not boot on next restart, because the bootloader will be configured to look for filesystems that don't exist.

**You must regenerate this file for your hardware.** Do so *before* the first rebuild:

```fish
sudo nixos-generate-config --show-hardware-config > /tmp/hw-new.nix
```

Then open `~/.config/nixos/hardware-configuration.nix` in an editor and compare it against `/tmp/hw-new.nix`. Merge in the differences for:

- `fileSystems."/"` — disk and partition UUIDs
- `fileSystems."/boot"` — ESP mount
- `swapDevices` — if any
- `boot.initrd.availableKernelModules` and `boot.kernelModules` — chipset-specific drivers
- `hardware.cpu.*` — CPU microcode and instruction-set variants

If you don't want to diff manually, the simplest path is:

```fish
cp ~/.config/nixos/hardware-configuration.nix ~/.config/nixos/hardware-configuration.nix.original
cp /tmp/hw-new.nix ~/.config/nixos/hardware-configuration.nix
```

…and then re-add any custom bits from `.original` (e.g. extra mounts) by hand.

> **A warning about the CachyOS kernel.** My config uses `linuxPackages-cachyos-latest-x86_64-v3`, which requires an Intel Haswell / AMD Excavator CPU or newer (AVX2, BMI2, FMA). If your new machine is older, change the `boot.kernelPackages` line in `configuration.nix` to `pkgs.linuxPackages` before rebuilding — otherwise the kernel will refuse to boot.

### Step 9 — First rebuild

Do this **manually**, not via `rebuild-sync`, for the first run. The reason is that `rebuild-sync` asks the running hostname for the flake attribute, and on a fresh install the running hostname may not yet be `nixos`.

```fish
sudo nixos-rebuild switch --flake ~/.config/nixos#nixos
```

Watch the output. If it fails, read the error carefully — nine times out of ten it's a `hardware-configuration.nix` mismatch, a wrong kernel variant, or a package that no longer exists in the current nixpkgs. Fix, re-run.

If it succeeds, reboot. On the next boot, `hostname` will return `nixos` (because `networking.hostName = "nixos"` is now active), and `rebuild-sync` will find the flake attribute on its own.

### Step 10 — Re-authenticate everything the backup doesn't carry

The backup deliberately does not contain secrets or session state. After the first rebuild, log back into the things that matter:

| Service | How to re-authenticate |
|---|---|
| Tailscale | `sudo tailscale up` — will open a browser for login |
| Steam | Launch Steam, log in, and re-add any 2FA |
| Firefox | Sign into Firefox Sync or copy profile manually |
| Git remotes | If you use HTTPS elsewhere, you may need new PATs |
| Samba | `sudo smbpasswd -a shadrack` — the password is not stored |
| SSH to other machines | Generate new keys, add public keys to servers |
| GPG | Restore from an offline backup if you used it |

### Step 11 — Run `rebuild-sync` for the first time

Now that `hostname` matches, run the script:

```fish
~/.local/bin/rebuild-sync
```

It should:

1. Rebuild (this time a no-op, since you just built).
2. Rsync the dotfiles into `~/.sysbackup` — expect a small number of changes, maybe zero.
3. Gitleaks scan — expect clean.
4. Commit — if there are changes.
5. Push — should succeed now that SSH keys are set up.

If the push succeeds, you're done. If it fails, read the log at `~/.sysbackup/backup.log` and work through [Troubleshooting](#troubleshooting).

### Step 12 — Restore anything else you want

The backup is deliberately minimal. If you had other things (SSH keys, GPG keys, code projects, media), restore them from wherever you kept them.

---

## Day-to-day usage

The workflow is one command, every time I change something:

```fish
nixbuild
```

That's it. It rebuilds, backs up, scans, commits, and pushes.

If I want to update the flake inputs first (to pick up new nixpkgs releases), I use:

```fish
nixupdate
```

…which is `nix flake update` followed by `nixbuild`.

### Recovering a deleted file

The rsync uses `--backup --backup-dir`, so every file it deletes or overwrites is first saved into a timestamped trash directory. Look there:

```fish
ls -1 ~/.sysbackup/.trash/ | tail -5
```

Pick the timestamp that's likely to contain the file you want, then browse:

```fish
find ~/.sysbackup/.trash/20260920-143022-XXXXXX -type f
```

The relative paths inside the trash directory mirror the backup's own layout. Copy the file out and put it back where it belongs.

### Rolling back a single file

Because the backup is a Git repo, you can also just use `git`:

```fish
git -C ~/.sysbackup log --oneline -- config/hypr/hyprland.lua
git -C ~/.sysbackup show <commit>:config/hypr/hyprland.lua > /tmp/old.lua
```

Or check out a specific version into the working tree:

```fish
git -C ~/.sysbackup checkout <commit> -- config/hypr/hyprland.lua
cp ~/.sysbackup/config/hypr/hyprland.lua ~/.config/hypr/hyprland.lua
```

### Rolling back a system change

NixOS keeps every system generation, so you can always boot the previous one:

```fish
sudo nixos-rebuild switch --rollback
```

Or, if you want to actually revert the config:

```fish
cd ~/.config/nixos
git log --oneline
git revert <bad-commit>
sudo nixos-rebuild switch --flake ~/.config/nixos#nixos
```

### Pruning the trash

The trash directory grows over time. Prune anything older than 30 days:

```fish
find ~/.sysbackup/.trash -maxdepth 1 -type d -mtime +30 -exec rm -rf {} +
```

### Adding a path to the backup

Edit the `syncs` list inside `~/.local/bin/rebuild-sync`:

```fish
set -l syncs \
    $FLAKE_DIR/                           $BACKUP_DIR/nixos/ \
    $HOME/.config/mpv/                    $BACKUP_DIR/config/mpv/ \
    $HOME/.config/hypr/                   $BACKUP_DIR/config/hypr/ \
    $HOME/.config/fish/                   $BACKUP_DIR/config/fish/ \
    $HOME/.local/bin/                     $BACKUP_DIR/local/bin/
```

Add a new source–destination pair, keeping the list even-length. The script validates this at startup and will refuse to run if you get it wrong.

---

## What's actually in the Nix config

I won't walk you through every line — the NixOS wiki does that better than I can. Instead, here's a map of which parts of `configuration.nix` do what, with links to the relevant upstream docs.

### System identity
Defines `hostname = nixos`, user `shadrack`, time zone `Africa/Nairobi`, and `stateVersion = "26.05"`.
→ [NixOS Wiki: User management](https://wiki.nixos.org/wiki/User_management), [NixOS Wiki: Timezone](https://wiki.nixos.org/wiki/Timezone)

### Boot & kernel
GRUB on EFI with the NixOS GRUB2 theme. CachyOS kernel via the [`nix-cachyos-kernel`](https://github.com/xddxdd/nix-cachyos-kernel) flake input. Sysctl IP-forwarding enabled for Tailscale subnet routing.
→ [NixOS Wiki: Bootloader](https://wiki.nixos.org/wiki/Bootloader), [NixOS Wiki: Linux kernel](https://wiki.nixos.org/wiki/Linux_kernel), [NixOS Wiki: Networking](https://wiki.nixos.org/wiki/Networking)

### Graphics
Intel graphics, 32-bit enabled (required for Proton / DirectX translation), with `intel-media-driver`, `intel-vaapi-driver`, and `libvdpau-va-gl`.
→ [NixOS Wiki: Accelerated video playback](https://wiki.nixos.org/wiki/Accelerated_Video_Playback)

### Networking & firewall
NetworkManager, Tailscale, and a firewall that opens Steam Remote Play (`30000–50000/TCP`), LocalSend (`53317`), and Tailscale (`41641/UDP`).
→ [NixOS Wiki: Networking](https://wiki.nixos.org/wiki/Networking), [NixOS Wiki: Firewall](https://wiki.nixos.org/wiki/Firewall), [NixOS Wiki: Tailscale](https://wiki.nixos.org/wiki/Tailscale)

### Desktop environment
Hyprland on Wayland, with `uwsm` for session management and `dms-shell` / `dms-greeter` for the shell and login screen. XWayland enabled for game compatibility.
→ [NixOS Wiki: Hyprland](https://wiki.nixos.org/wiki/Hyprland), [UWSM](https://github.com/Vladimir-csp/uwsm)

### Gaming
Steam with Remote Play, dedicated-server, and LAN transfer firewalls open, plus Proton-GE via `extraCompatPackages`. `gamemode` enabled system-wide.
→ [NixOS Wiki: Steam](https://wiki.nixos.org/wiki/Steam)

### Virtualization
Waydroid using the `waydroid-nftables` variant, with the helper package and mount service wired up.
→ [NixOS Wiki: Waydroid](https://wiki.nixos.org/wiki/Waydroid)

### File sharing
Samba, read-only shares for `~/Videos` and `~/Music`, authentication required.
→ [NixOS Wiki: Samba](https://wiki.nixos.org/wiki/Samba)

### Shell, editor, terminal
`fish` as the login shell, `ghostty` as the terminal, `zed-editor` as the GUI editor, `nil` and `nixd` as Nix LSPs.
→ [NixOS Wiki: Fish](https://wiki.nixos.org/wiki/Fish)

### Themes and cursor
`adwaita-icon-theme`, `breeze-hacked-cursor-theme`, `candy-icons`, and Qt theme engines (`qt5ct`, `qt6ct`).
→ [NixOS Wiki: Fonts](https://wiki.nixos.org/wiki/Fonts)

### MPV
MPV with the `mpris`, `sponsorblock`, `quality-menu`, `mpv-playlistmanager`, and `thumbfast` scripts pre-baked via override.
→ [NixOS Wiki: MPV](https://wiki.nixos.org/wiki/MPV)

If you want to change something, edit `configuration.nix` and run `nixbuild`. If you want to remove a whole section, delete it — nothing else depends on it except in the obvious ways (remove Steam and its firewall rules become redundant, etc.).

---

## Security model

I have a **private** GitHub repo, and I do not want secrets reaching it. The controls in place:

| Control | Protects against |
|---|---|
| `gitleaks git --staged` | API keys, tokens, passwords accidentally committed. |
| `--exclude=.git` in rsync | Nested git repos being versioned as gitlinks. |
| `.gitignore` bootstrap | Runtime state (`.lock`, `.push_pending`, `.trash/`) leaking into history. |
| Explicit `syncs` list | Arbitrary home-directory contents being captured. |
| No secrets in the flake | `configuration.nix` contains no passwords or keys. |
| `flock -n` | Two concurrent runs interleaving writes. |

**What is *not* protected:**

- **The remote.** If my GitHub account is compromised, the attacker has everything in the backup. Do not treat a private repo as a vault.
- **The local backup repo.** It's a plain Git directory. Full-disk encryption is assumed.
- **The log file.** `backup.log` is tracked, so anything logged goes to the remote. The script logs paths and status, not file contents.
- **Trash directories.** These are gitignored but present on disk. They contain deleted files, which could be sensitive.

If you want to back up secrets, use [`sops-nix`](https://github.com/Mic92/sops-nix) or [`agenix`](https://github.com/ryantm/agenix) and commit *encrypted* files. The gitleaks scan will not flag them, because they're ciphertext.

---

## Troubleshooting

### `flake '...' does not provide attribute 'nixosConfigurations.<host>'`

Your running `hostname` doesn't match the flake attribute. Check:

```fish
hostname
nix eval ~/.config/nixos#nixosConfigurations --apply builtins.attrNames
```

If they differ, either rebuild once with an explicit target:

```fish
sudo nixos-rebuild switch --flake ~/.config/nixos#nixos
```

…or export the override for one run:

```fish
set -x NIXBUILD_FLAKE_HOST nixos
~/.local/bin/rebuild-sync
```

### `error: path '...' is not tracked by Git`

The flake references a file that isn't staged. The script does `git add .` in `~/.config/nixos` automatically, but if that failed (e.g. `~/.config/nixos` isn't a git repo), do it manually:

```fish
git -C ~/.config/nixos add .
```

### `Permission denied (publickey)` when pushing

Your SSH key isn't loaded or isn't on GitHub. Check:

```fish
ssh -T git@github.com
ssh-add -l
```

If `ssh-add -l` prints "The agent has no identities", add your key:

```fish
ssh-add ~/.ssh/id_ed25519
```

If that says the key doesn't exist, generate one — see [Prerequisites step 4](#4-generate-an-ssh-key-and-add-it-to-github).

### `unknown flag: --staged` from gitleaks

Your gitleaks is older than the version that added `--staged` to the `git` subcommand. Either upgrade:

```fish
nix profile upgrade gitleaks
```

Or, in `local/bin/rebuild-sync`, change the gitleaks invocation to:

```fish
gitleaks protect --staged --no-banner --redact --exit-code 1 --source $BACKUP_DIR
```

### Push keeps failing

Check connectivity:

```fish
git -C ~/.sysbackup ls-remote origin
```

If it hangs, the remote is unreachable. The script leaves a `.push_pending` marker; fix the network and run `rebuild-sync` again.

### Rebase conflict during pull

The script aborts the rebase automatically. Resolve it by hand:

```fish
cd ~/.sysbackup
git status
# Fix conflicts, then:
git add <fixed-files>
git rebase --continue
git push origin main
```

### The script says another instance is running

`flock` releases on process exit, so this shouldn't happen. Verify with:

```fish
fuser ~/.sysbackup/.lock
```

If nothing prints, the file isn't actually locked — retry. If a PID prints, that process is alive and holding the lock. Either wait or kill it.

### `rsync` exit code 24

This is "some source files vanished during transfer". Usually a temp file. The script treats it as a warning, not an error. Safe to ignore.

### A file I deleted is still in the backup

`--delete-after` removes it from the destination on the *next* run. Run `rebuild-sync` once more.

### The log file is enormous

Trim it:

```fish
tail -n 5000 ~/.sysbackup/backup.log > /tmp/log
mv /tmp/log ~/.sysbackup/backup.log
git -C ~/.sysbackup add backup.log
git -C ~/.sysbackup commit -m "chore: prune backup.log"
git -C ~/.sysbackup push
```

---

## FAQ

**Why not use Home Manager?**
I have a strong preference for keeping things at one layer. Home Manager is a *second* configuration language alongside NixOS modules, and I'd rather have one. If you want Home Manager, you can add it as a flake input without disturbing anything else here.

**Why a separate backup repo at all?**
Because dotfiles change on a very different cadence than `configuration.nix`. Mixing them pollutes the flake's history with unrelated churn and makes reverting a config change messy. Two repos, two histories, one script to keep them in sync.

**Why two repos if I only push one to GitHub?**
The flake at `~/.config/nixos` is *also* a git repo — I commit there manually when I want a checkpoint. But I don't push the flake's own history anywhere; instead, `rebuild-sync` rsyncs its *working tree* into the backup repo, stripping `.git/`. So the backup captures the *contents* of the flake but not its commit graph. That's a deliberate simplification — the backup's own history is enough.

**Can I run this from a systemd timer?**
Yes:

```nix
systemd.user.services.rebuild-sync = {
  description = "NixOS rebuild + backup sync";
  serviceConfig.Type = "oneshot";
  serviceConfig.ExecStart = "%h/.local/bin/rebuild-sync";
};

systemd.user.timers.rebuild-sync = {
  wantedBy = [ "timers.target" ];
  timerConfig.OnCalendar = "daily";
  timerConfig.Persistent = true;
};
```

`notify-send` will silently no-op in this context because there's no session bus, which is the correct behaviour.

**Can I back up without rebuilding?**
The current script always rebuilds first. If you want a backup-only mode, guard the rebuild block with a variable check:

```fish
if not set -q NIXBUILD_SKIP_REBUILD
    # rebuild block goes here
end
```

Then:

```fish
set -x NIXBUILD_SKIP_REBUILD 1
~/.local/bin/rebuild-sync
```

**What happens if the machine dies mid-run?**
`flock` is released automatically. Any files copied but not committed stay in the working tree; the next run re-rsyncs and picks up where it left off. Nothing is lost because `--delete-after` only runs after a successful transfer, and `--backup` preserves anything overwritten.

**What if I want to back up a path that doesn't exist yet?**
The script skips missing sources with a warning. Add the path to the `syncs` list; it starts being backed up as soon as it exists.

**How do I add a second machine?**
Two options. (a) Duplicate the flake, change the hostname in `flake.nix` and `configuration.nix`, and point a second backup repo at a second GitHub remote. (b) Use branches on this repo — `main` for this machine, `laptop` for another, and set `BRANCH` in the script per-machine. The script assumes one host per invocation, so (b) requires changing the constant.

**Why `Africa/Nairobi`?**
Because that's where I am.

---

## Links

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Wiki](https://wiki.nixos.org/) — the canonical reference for every `services.*`, `programs.*`, and `hardware.*` option used here.
- [Nix Flakes](https://wiki.nixos.org/wiki/Flakes)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [nix-cachyos-kernel](https://github.com/xddxdd/nix-cachyos-kernel)
- [gitleaks](https://github.com/gitleaks/gitleaks)
- [rsync manual](https://download.samba.org/pub/rsync/rsync.1)
- [Fish shell docs](https://fishshell.com/docs/current/)
- [UWSM](https://github.com/Vladimir-csp/uwsm)
- [nix-output-monitor](https://github.com/maralorn/nix-output-monitor)

---

<div align="center">

**Maintained by** [@LadyHawk2006](https://github.com/LadyHawk2006)
**Hostname** `nixos` · **User** `shadrack`
**Repository** <https://github.com/LadyHawk2006/NixOS>

<sub>This README lives in the backup repo, so it survives any restore.</sub>

</div>
