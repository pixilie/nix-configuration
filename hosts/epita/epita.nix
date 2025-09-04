{ pkgs, inputs, ... }:

{
  imports = [
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/helix.nix
    ../../modules/home-manager/sh.nix
    ../../modules/home-manager/fonts.nix
    ../../modules/options.nix
    ../../modules/home-manager/display/i3.nix
    ../../modules/special-packages.nix
  ];

  home.username = "kristen.couty";
  home.homeDirectory = "/home/kristen.couty";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    nautilus
    inputs.tidaLuna.packages.${system}.default
  ];

  programs.home-manager.enable = true;
}
