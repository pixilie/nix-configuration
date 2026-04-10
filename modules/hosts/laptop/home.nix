{ self, inputs, ... }: {

  flake.homeModules.laptopHome = { pkgs, upkgs, ... }: {
    imports = [
      self.homeModules.gtk
      self.homeModules.gammastep
      
      self.homeModules.git
      self.homeModules.helix
      self.homeModules.zed
      self.homeModules.sh
      self.homeModules.fonts
      self.homeModules.tools
      self.homeModules.xdg
      self.homeModules.ssh

      self.homeModules.options
      self.homeModules.specialPackages
    ];

    # General informations
    home.username = "kristen";
    home.homeDirectory = "/home/kristen";
    home.stateVersion = "25.11";

    # Packages
    home.packages = with pkgs; [
      vesktop
      spotify
      bitwarden-desktop
      nautilus
      firefox
      gimp-with-plugins
      teams-for-linux
      onlyoffice-desktopeditors
      image-roll
      obs-studio
      vlc
      localsend
      pavucontrol
      gnome-calculator
      baobab
      wdisplays
      networkmanagerapplet
      upkgs.lunar-client
      prismlauncher
      jdk25
      heroic
      dbeaver-bin
      arduino-ide
    ];

    # Reload system units when switching config
    systemd.user.startServices = "sd-switch";

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };

}
