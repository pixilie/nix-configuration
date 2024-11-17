{ pkgs, upkgs, inputs, ... }:

{
  imports = [
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/helix.nix
    ../../modules/home-manager/sway.nix
    ../../modules/home-manager/sh.nix
    ../../modules/home-manager/mako.nix
    ../../modules/home-manager/fonts.nix
    ../../modules/home-manager/unfree.nix
  ];

  # General informations
  home.username = "kristen";
  home.homeDirectory = "/home/kristen";
  home.stateVersion = "24.05";

  # Packages
  home.packages = with pkgs; [
    firefox
    vesktop
    thunderbird
    tidal-hifi
    bitwarden-desktop

    # Dev related
    # TODO: Wait HM update for the fix
    wakatime
    inputs.wakatime-lsp.packages."x86_64-linux".wakatime-lsp
    nil
    nixfmt-classic
    python3
    python312Packages.python-lsp-server
    gccgo14
    rustup
    jetbrains-toolbox
    upkgs.unityhub

    # Window manager
    wlroots
    sway
    wayland
    swaylock-effects
    swayidle
    swaybg
    xwayland
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
