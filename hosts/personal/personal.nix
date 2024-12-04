{ pkgs, upkgs, ... }:

{
  imports = [
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/helix.nix
    ../../modules/home-manager/sh.nix
    ../../modules/home-manager/fonts.nix
    ../../modules/special-packages.nix
    ../../modules/home-manager/tools.nix
    ../../modules/home-manager/display/sway.nix
    ../../modules/home-manager/display/mako.nix
  ];

  # General informations
  home.username = "kristen";
  home.homeDirectory = "/home/kristen";
  home.stateVersion = "24.05";

  # Packages
  home.packages = with pkgs; [
    vesktop
    tidal-hifi
    bitwarden-desktop
    skypeforlinux
    prismlauncher
    masterpdfeditor
    lunar-client
    insomnia
    nautilus
    firefox

    # Dev related
    jetbrains-toolbox
    upkgs.unityhub
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
