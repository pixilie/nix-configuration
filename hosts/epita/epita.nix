{ pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/helix.nix
    ../../modules/home-manager/sh.nix
    ../../modules/home-manager/fonts.nix
  ];

  # General informations
  home.username = "kristen.couty";
  home.homeDirectory = "/home/kristen.couty";
  home.stateVersion = "24.11";

  # Packages
  home.packages = with pkgs; [ tidal-hifi ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
