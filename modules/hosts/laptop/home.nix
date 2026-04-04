{ self, inputs, ... }: {

  flake.homeModules.laptopHome = { pkgs, upkgs, ... }: {
    imports = [

    ];

    # General informations
    home.username = "kristen";
    home.homeDirectory = "/home/kristen";
    home.stateVersion = "25.11";

    # Packages
    home.packages = with pkgs; [
      discord spotify bitwarden-desktop nautilus firefox
      gimp-with-plugins teams-for-linux logseq element-desktop
      onlyoffice-desktopeditors image-roll obs-studio vlc
      localsend pavucontrol gnome-calculator baobab wdisplays
      networkmanagerapplet upkgs.lunar-client prismlauncher
      jdk21 heroic dbeaver-bin arduino-ide
    ];

    # Reload system units when switching config
    systemd.user.startServices = "sd-switch";

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };

}
