# ❄️ NixOS & Home Manager Configuration

Welcome to my personal, modular, and flake-based [NixOS](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager) configuration.

This repository contains declarative configurations for my personal laptop and my school (EPITA) environment, featuring dynamic theming, multiple window managers, and dedicated development environments.

---

## 📂 Repository Structure

```text
.
├── assets/          # Media (wallpapers), static configs (Zellij), and themes (Rofi, Waybar)
├── modules/         # Core configuration modules
│   ├── features/    # Reusable modular blocks
│   │   ├── core/    # CLI tools, Fish shell, Git, SSH, XDG
│   │   ├── desktop/ # WMs (Niri, Sway, i3), Waybar, Fonts, GTK, SDDM, Noctalia
│   │   ├── dev/     # Helix, Zed, Git configurations
│   │   ├── gaming/  # Steam, Gamemode
│   │   └── system/  # Network, Bluetooth, Audio (Pipewire), Docker, Power Management
│   └── hosts/       # Host-specific configurations
│       ├── laptop/  # Personal NixOS + Home Manager setup (Niri/Sway)
│       └── epita/   # Standalone Home Manager setup (i3) for school
├── templates/       # Nix flake templates for various programming languages
└── flake.nix        # The entry point of the system
```

## 🚀 Installation & Usage

For the ``laptop`` NixOS profile:
```bash
# Update the OS configuration
nh os switch . -H laptop

# Update the Home Manager configuration
nh home switch . -c laptop
```

For the ``epita`` Home Manager profile:
```bash
# Apply the home configuration
nh home switch . -c epita
```

Alternatively, using standard Nix commands:
```bash
nixos-rebuild switch --flake .#laptop --use-remote-sudo
home-manager switch --flake .#laptop

home-manager switch --flake .#epita
```

## 🛠️ Development Templates

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
