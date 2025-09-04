{ pkgs, upkgs, inputs, ... }: {
  imports = [
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/helix.nix
    ../../modules/home-manager/zed.nix
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
  home.stateVersion = "25.05";

  # Packages
  home.packages = with pkgs; [
    # General apps
    vesktop
    inputs.tidaLuna.packages.${system}.default

    bitwarden-desktop
    nautilus
    firefox
    google-chrome
    gnote

    gimp-with-plugins
    kdePackages.kdenlive

    thunderbird
    teams-for-linux
    zoom-us
    rustdesk
    whatsie
    libreoffice-still-unwrapped

    # Dev related
    jetbrains-toolbox
    upkgs.unityhub
    upkgs.zed-editor
    insomnia
    vscode

    # Games
    upkgs.lunar-client
    prismlauncher
  ];

  services.kdeconnect.enable = true;

  # Reload system units when switching config
  systemd.user.startServices = "sd-switch";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
