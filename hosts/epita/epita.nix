{ pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/display/i3/i3.nix

    ../../modules/home-manager/git.nix
    ../../modules/home-manager/helix.nix
    ../../modules/home-manager/sh.nix
    ../../modules/home-manager/fonts.nix

    ../../modules/options.nix
  ];

  config = {
    # Set to false to use the latest version of Helix (and not th one cached by nixpkgs)
    useHelixCache = true;
    isSchoolProfile = true;

    home.username = "kristen.couty";
    home.homeDirectory = "/home/kristen.couty";
    home.stateVersion = "25.11";

    home.packages = with pkgs; [
      nautilus
      spotify
    ];

    programs.home-manager.enable = true;
  };
}
