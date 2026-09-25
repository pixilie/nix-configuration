# ❄️ NixOS & Home Manager Configuration

Welcome to my personal, modular, and flake-based [NixOS](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager) configuration.

This repository contains declarative configurations for my personal laptop and my school (EPITA) environment, featuring dynamic theming, multiple window managers, and dedicated development environments.

---

## 📂 Repository Structure

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
decrypt them.

A single dedicated ssh key, ``~/.ssh/secret``, is the age identity of every profile — it exists
only to unlock these secrets, and is deliberately separate from the git signing and
authentication keys. Its path is exposed as ``secrets.identityFile``. Decryption runs in the
``sops-nix`` user service, at login and on every activation. Rendered files land in
``$XDG_RUNTIME_DIR``, never in the nix store nor in the repository.

``~/.wakatime.cfg`` is produced that way through ``sops.templates``, so the wakapi API key
only ever exists in clear in a ``0400`` file inside the runtime directory.

Every new machine needs ``~/.ssh/secret`` copied over, mode ``0600``. Nothing else: the
encrypted payload comes from the repository.

To edit the secrets:

```bash
make secrets                        # decrypts with ~/.ssh/secret
make secrets IDENTITY=~/.ssh/other  # override the identity
```

Rotating the key means generating a new one, replacing the recipient in ``.sops.yaml``
(``ssh-to-age < ~/.ssh/secret.pub``) and running ``sops updatekeys secrets/secrets.yaml``
while the old key is still available to decrypt. The key must be ed25519 and passphrase-less,
since the service decrypts unattended.

## 🚀 Installation & Usage

Every profile has a ``make`` target:

```bash
make rebuild      # NixOS system  (laptop)
make home         # Home Manager  (laptop)
make epita-light  # Home Manager  (epita)
make rpi          # NixOS system  (raspberry pi, over ssh)
make rpi-image    # Flashable SD image (raspberry pi)
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

## 🍓 Raspberry Pi

The ``rpi`` host is a headless Raspberry Pi 3 running NixOS, with the same fish / starship
setup as the other profiles (through Home Manager as a NixOS module).

It only accepts ssh key authentication, as ``kristen``, with ``~/.ssh/rpi``. The public half
lives in ``assets/keys/rpi.pub``; the private key stays on the laptop. The laptop ssh config
already knows the host, so ``ssh rpi`` is enough — the Pi announces itself as ``rpi.local``
over mDNS once it has an address from DHCP on ethernet.

The image is aarch64, so the laptop builds it through qemu emulation
(``boot.binfmt.emulatedSystems``, run ``make rebuild`` once before the first build):

```bash
make rpi-image
sudo dd if=result/sd-image/nixos-image-sd-card-*.img of=/dev/sdX bs=4M status=progress conv=fsync
```

The root partition grows to the whole card on first boot. Afterwards, the configuration is
deployed from the laptop with ``make rpi``, which builds locally and switches the Pi over ssh
(``kristen`` has passwordless sudo there, since there is no password to type).

Reflashing the card generates new host keys, so the old ``rpi.local`` entry has to be dropped
from ``~/.ssh/known_hosts`` with ``ssh-keygen -R rpi.local``.

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
