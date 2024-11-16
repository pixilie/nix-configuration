{ pkgs, upkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/helix.nix
    ../../modules/home-manager/sway.nix
    ../../modules/home-manager/sh.nix
    ../../modules/home-manager/mako.nix
    ../../modules/home-manager/fonts.nix
  ];

  # General informations
  home.username = "kristen";
  home.homeDirectory = "/home/kristen";
  home.stateVersion = "24.05";

  # Packages
  home.packages = with pkgs; [
    # Unfree
    jetbrains-toolbox
    steam
    upkgs.unityhub

    # Free
    firefox
    vesktop
    thunderbird
    tidal-hifi
    bitwarden-desktop

    # Dev related
    git
    helix
    upkgs.zed-editor
    wakatime
    inputs.wakatime-lsp.packages."x86_64-linux".wakatime-lsp
    nil
    nixfmt-classic
    python3
    python312Packages.python-lsp-server
    gccgo14
    rustup

    # Shell related
    fish
    starship
    eza
    gitui
    yazi
    kitty
    tokei
    bat

    # Window manager
    wlroots
    sway
    wayland
    swaylock-effects
    swayidle
    swaybg
    mako
    xwayland
    i3status-rust
    fuzzel
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "jetbrains-toolbox"
      "steam-original"
      "steam"
      "unityhub"
    ];

  # Low power alert
  services.poweralertd.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
