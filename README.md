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
│   │   ├── dev/     # Helix, Zed, Vim, Git, WakaTime configurations
│   │   ├── gaming/  # Steam, Gamemode
│   │   └── system/  # Network, Bluetooth, Audio (Pipewire), Docker, Power Management
│   └── hosts/            # Host-specific configurations
│       ├── laptop/       # Personal NixOS + Home Manager setup (Niri/Sway)
│       └── epita_light/  # Standalone Home Manager setup (i3) for school
├── secrets/         # sops encrypted secrets
├── templates/       # Nix flake templates for various programming languages
├── Makefile         # Entry point for every profile
├── .envrc           # direnv hook loading the flake dev shell (provides make)
├── .sops.yaml       # age recipients allowed to decrypt the secrets
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

## 🔐 Secrets

Secrets live encrypted in `secrets/secrets.yaml`, handled by
[sops-nix](https://github.com/Mic92/sops-nix). `.sops.yaml` lists the age recipients allowed to
decrypt them, derived from the ssh public key of each profile.

Every profile decrypts with the ssh private key it already owns — ``~/.ssh/github`` on the
laptop, ``~/.ssh/epita`` at school — selected through ``secrets.identityFile``. Decryption runs
in the ``sops-nix`` user service, at login and on every activation. Rendered files land in
``$XDG_RUNTIME_DIR``, never in the nix store nor in the repository.

``~/.wakatime.cfg`` is produced that way through ``sops.templates``, so the wakapi API key
only ever exists in clear in a ``0400`` file inside the runtime directory.

To edit the secrets:

```bash
make secrets                          # decrypts with ~/.ssh/github
make secrets IDENTITY=~/.ssh/epita    # from a school machine
```

Adding a machine means appending its age recipient to ``.sops.yaml``
(``ssh-to-age < ~/.ssh/<key>.pub``) then running ``sops updatekeys secrets/secrets.yaml``.
Keys must be ed25519 and passphrase-less.

## 🚀 Installation & Usage

Every profile has a ``make`` target:

```bash
make rebuild      # NixOS system  (laptop)
make home         # Home Manager  (laptop)
make epita-light  # Home Manager  (epita)
```

``rebuild`` and ``home`` go through [nh](https://github.com/nix-community/nh). The ``epita-light``
target builds the activation package and runs it directly, so nothing beyond Nix itself is
required on the school machines.

``make`` itself ships with the repository, through the flake dev shell — no system-wide
install needed. With [direnv](https://direnv.net/) it loads on ``cd``; otherwise, or on a
machine that has nothing set up yet:

```bash
nix develop --command make epita-light
```

Alternatively, using standard Nix commands:
```bash
nixos-rebuild switch --flake .#laptop --use-remote-sudo
home-manager switch --flake .#laptop

home-manager switch --flake .#epita_light
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
