{ ... }:

{
  imports = [
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/helix.nix
    ../../modules/home-manager/sh.nix
    ../../modules/home-manager/fonts.nix
    ../../modules/options.nix
    ../../modules/home-manager/display/i3.nix
  ];

  config = {
    useCache = true;
  
    home.username = "kristen.couty";
    home.homeDirectory = "/home/kristen.couty";
    home.stateVersion = "25.05";

    programs.home-manager.enable = true;
  };
}
