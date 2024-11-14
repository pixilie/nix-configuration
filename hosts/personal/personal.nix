{ config, pkgs, lib, inputs, ... }:

{ 
  imports = [
    ../../fragments/home-manager/git.nix
    ../../fragments/home-manager/helix.nix
    ../../fragments/home-manager/sway.nix
    ../../fragments/home-manager/bar.nix
    ../../fragments/home-manager/sh.nix
    ../../fragments/home-manager/mako.nix
    ../../fragments/nixos/fonts.nix
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
    unityhub
    
    # Free
    firefox
    vesktop
    thunderbird
    tidal-hifi
    bitwarden-desktop    

    # Dev related
    git
    helix
    wakatime
    inputs.wakatime-lsp.packages."x86_64-linux".wakatime-lsp
    nil
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
    swaylock
    swayidle
    wofi
    swaybg
    mako
    xwayland
    i3status-rust
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "jetbrains-toolbox"
    "steam-original"
    "steam"
    "unityhub"
  ];

  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
