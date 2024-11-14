{ config, pkgs, lib, inputs, ... }:

{ 
  imports = [
    ../../fragments/home-manager/git.nix
    ../../fragments/home-manager/helix.nix
    ../../fragments/home-manager/sway.nix
    ../../fragments/home-manager/bar.nix
    ../../fragments/home-manager/sh.nix
    ../../fragments/home-manager/mako.nix
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
    rustc
    cargo
    rust-analyzer
    clippy
    gccgo14
        
    # Shell related
    fish
    starship
    eza
    gitui
    yazi
    kitty
    tokei
    
    # Fonts
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    noto-fonts
    font-awesome
        
    # Tools
    grim
    slurp
    wl-clipboard
    killall
    brightnessctl
    tree
    wireplumber
    networkmanagerapplet
    unzip
    poweralertd
    upower
    
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

  # Enable fonts in home-manager
  fonts.fontconfig.enable = true;
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
