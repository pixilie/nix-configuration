{ pkgs, upkgs, ... }:

{
  imports = [
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/helix.nix
    ../../modules/home-manager/sh.nix
    ../../modules/home-manager/fonts.nix
    ../../modules/home-manager/tools.nix
    ../../modules/home-manager/display/sway.nix
    ../../modules/home-manager/display/mako.nix
    ../../modules/home-manager/xdg.nix
    ../../modules/options.nix
    ../../modules/special-packages.nix
  ];

  # General informations
  home.username = "kristen";
  home.homeDirectory = "/home/kristen";
  home.stateVersion = "24.11";

  # Packages
  home.packages = with pkgs; [
    # General apps
    vesktop
    tidal-hifi
    bitwarden-desktop
    skypeforlinux
    masterpdfeditor
    nautilus
    firefox
    google-chrome

    # Dev related
    jetbrains-toolbox
    upkgs.unityhub
    zed-editor
    insomnia

    # Games
    superTuxKart
    lunar-client
    prismlauncher
    ferium
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
