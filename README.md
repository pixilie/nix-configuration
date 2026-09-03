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
│   │   ├── core/    # CLI tools, Fish shell, Git, SSH, XDG, per-profile identity
│   │   ├── desktop/ # WMs (Niri, Sway, i3), Waybar, Fonts, GTK, SDDM, Noctalia
│   │   ├── dev/     # Helix, Zed, Git configurations
│   │   ├── gaming/  # Steam, Gamemode
│   │   └── system/  # Network, Bluetooth, Audio (Pipewire), Docker, Power Management
│   └── hosts/            # Host-specific configurations
│       ├── laptop/       # Personal NixOS + Home Manager setup (Niri/Sway)
│       ├── epita/        # Standalone Home Manager setup (i3) for school
│       └── epita_light/  # Same, stripped down to the bare minimum
├── templates/       # Nix flake templates for various programming languages
├── Makefile         # Entry point for every profile
└── flake.nix        # The entry point of the system
```

## 🪪 Per-profile identity

Name, email and commit signing key differ between the personal and the school profiles,
so they are declared per host in ``modules/hosts/<host>/home.nix``:

```nix
identity = {
  name = "Kristen Couty";
  email = "kristen.couty@epita.fr";
  signingKey = "${config.home.homeDirectory}/.ssh/epita.pub";
};
```

``signingKey`` defaults to ``~/.ssh/github.pub``. The options live in
``modules/features/core/identity.nix``, and ``~/.ssh/allowed_signers`` is regenerated from
them on every activation so git can verify its own signatures.

---

## 🚀 Installation & Usage

Every profile has a ``make`` target:

```bash
make rebuild      # NixOS system  (laptop)
make home         # Home Manager  (laptop)
make epita        # Home Manager  (epita)
make epita-light  # Home Manager  (epita, minimal)
```

``rebuild`` and ``home`` go through [nh](https://github.com/nix-community/nh). The ``epita``
targets build the activation package and run it directly, so nothing beyond Nix itself is
required on the school machines.

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
