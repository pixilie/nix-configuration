{ pkgs, upkgs, ... }: {
  imports = [
    ../../modules/home-manager/display/sway.nix
    ../../modules/home-manager/display/mako.nix
    ../../modules/home-manager/display/darkman.nix
    ../../modules/home-manager/display/gammastep.nix
    ../../modules/home-manager/display/gtk.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/helix.nix
    ../../modules/home-manager/zed.nix
    ../../modules/home-manager/sh.nix
    ../../modules/home-manager/fonts.nix
    ../../modules/home-manager/tools.nix
    ../../modules/home-manager/xdg.nix
    ../../modules/home-manager/ssh.nix
    ../../modules/options.nix
    ../../modules/special-packages.nix
  ];

  # General informations
  home.username = "kristen";
  home.homeDirectory = "/home/kristen";
  home.stateVersion = "25.11";

  # Packages
  home.packages = with pkgs; [
    # General apps
    discord
    spotify
    bitwarden-desktop
    nautilus
    baobab
    firefox
    gimp-with-plugins
    teams-for-linux
    libreoffice-still
    logseq

    # Games
    upkgs.lunar-client
    prismlauncher
    # jdk17
    jdk8
    heroic
  ];

  # Reload system units when switching config
  systemd.user.startServices = "sd-switch";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
