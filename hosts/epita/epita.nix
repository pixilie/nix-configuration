{ pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/display/i3-bar.nix
    ../../modules/home-manager/display/i3.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/helix.nix
    ../../modules/home-manager/sh.nix
    ../../modules/home-manager/fonts.nix
    ../../modules/options.nix
    ../../modules/special-packages.nix
  ];

  config = {
    useHelixCache = true;
    
    home.username = "kristen.couty";
    home.homeDirectory = "/home/kristen.couty";
    home.stateVersion = "25.05";

    home.packages = with pkgs; [
      nautilus
      tidal-hifi
    ];

    programs.home-manager.enable = true;
  };
}
