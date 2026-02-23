{ pkgs, upkgs, ... }:
{
  imports = [
    ../../modules/home-manager/display/sway/sway.nix

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
    firefox
    gimp-with-plugins
    teams-for-linux
    libreoffice-still
    logseq
    element-desktop
    onlyoffice-desktopeditors
    image-roll

    # Utilities
    localsend
    pavucontrol
    gnome-calculator
    baobab
    wdisplays
    networkmanagerapplet

    # Games
    upkgs.lunar-client
    prismlauncher
    jdk21
    heroic

    # Dev related
    dbeaver-bin
    arduino-ide
  ];

  # Reload system units when switching config
  systemd.user.startServices = "sd-switch";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
