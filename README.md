# ❄️ NixOS & Home Manager Configuration

Welcome to my personal, modular, and flake-based [NixOS](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager) configuration.

This repository contains declarative configurations for my personal laptop, my school (EPITA) environment and my homelab setup.

---

## Repository Structure

```text
.
├── assets/          # Media (wallpapers), static configs (Zellij), themes (Rofi, Waybar), public ssh keys
├── modules/         # Core configuration modules
│   ├── features/    # Reusable modular blocks
│   │   ├── core/    # CLI tools, Fish shell, Git, SSH, XDG, per-profile identity
│   │   ├── desktop/ # WMs (Niri, Sway, i3), Waybar, Fonts, GTK, SDDM, Noctalia
│   │   ├── dev/     # Helix, Zed, Vim, Git, WakaTime configurations
│   │   ├── gaming/  # Steam, Gamemode
│   │   └── system/  # Network, Bluetooth, Audio (Pipewire), Docker, Power Management
│   └── hosts/            # Host-specific configurations
│       ├── laptop/       # Personal NixOS + Home Manager setup (Niri/Sway)
│       ├── epita_light/  # Standalone Home Manager setup (i3) for school
│       └── rpi/          # Headless Raspberry Pi 3 (SD image, ssh, fish)
├── secrets/         # sops encrypted secrets
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
