# ❄️ NixOS & Home Manager Configuration

Welcome to my personal, modular, and flake-based [NixOS](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager) configuration.

This repository contains declarative configurations for my personal laptop, my school (EPITA) environment and my homelab setup.

---

## Repository Structure

```text
.
├── assets/          # Wallpapers, Rofi themes, public ssh keys
├── modules/         # Every file is a flake-parts module, loaded through import-tree
│   ├── features/    # Reusable modular blocks
│   │   ├── core/    # CLI tools, Fish shell, SSH, XDG, secrets, per-profile identity, templates
│   │   ├── desktop/ # Alacritty, Firefox, Thunderbird, Fonts, GTK, Gammastep, Rofi, Vicinae
│   │   │   ├── i3/      # i3 (school profile)
│   │   │   └── sway/    # Sway, Waybar, Mako, SwayOSD, Darkman, Veila lock screen
│   │   ├── dev/     # Helix, Zed, Vim, Git, WakaTime configurations
│   │   ├── gaming/  # Steam, Gamemode
│   │   └── system/  # Network, Bluetooth, Audio (Pipewire), Docker, SDDM, Power Management
│   └── hosts/            # Host-specific configurations
│       ├── laptop/       # Personal NixOS + Home Manager setup (Sway)
│       ├── epita_light/  # Standalone Home Manager setup (i3) for school
│       ├── rpi/          # Headless Raspberry Pi 3: tailscale subnet router, gatus, ntfy, monitoring
│       ├── vps/          # OVH VPS: kalnu, immich, vaultwarden, maddy and other services
│       └── nas.nix       # Home NAS address shared by the rpi and vps hosts
├── secrets/         # sops encrypted secrets, one file per host
├── templates/       # Nix flake templates for various programming languages
├── Makefile         # Entry point for every profile
├── .envrc           # direnv hook loading the flake dev shell (provides make)
├── .sops.yaml       # age recipients allowed to decrypt the secrets
└── flake.nix        # The entry point of the system
```

## Development Templates

This repository includes several ready-to-use Nix flake templates for quick project initialization with direnv integration.
To initialize a new project, run:
```bash
nix flake init --template github:pixilie/nix-configuration#<template_name>
```

### Available Templates:
- ``c`` : Blank C project with Clang, LLDB, and clang-tools.
- ``csharp`` : Blank C# / .NET 8 project with csharp-ls and netcoredbg.
- ``python`` : Python project with pyright, ruff, and ipython.
- ``rust`` : Rust project using rust-overlay, rust-analyzer, and act.
