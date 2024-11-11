{ config, pkgs, lib, inputs, ... }:

{ 
  imports = [
    ../../fragments/home-manager/git.nix
    ../../fragments/home-manager/helix.nix
    ../../fragments/home-manager/sway.nix
    ../../framents/home-manager/bar.nix
    ../../fragments/home-manager/sh.nix
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
    
    # Shell related
    fish
    starship
    eza
    gitui
    yazi
    kitty
    
    # Fonts     
    font-awesome
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
    lm_sensors

    # Window manager
    wlroots
    sway
    wayland
    swaylock
    waybar
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
