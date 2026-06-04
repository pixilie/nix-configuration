{ self, inputs, ... }: {

  flake.homeModules.laptopHome = { pkgs, upkgs, ... }: {
    imports = [
      self.homeModules.gtk
      self.homeModules.darkmanSway
      self.homeModules.sway
      self.homeModules.sway_osd
      self.homeModules.swaylock
      self.homeModules.mako
      self.homeModules.waybar
      self.homeModules.rofi

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
      discord
      spotify
      psst
      bitwarden-desktop
      nautilus
      upkgs.firefox

      gimp-with-plugins
      onlyoffice-desktopeditors
      obs-studio
      localsend
      gnome-calculator

      baobab
      vlc
      image-roll
      pavucontrol
      wdisplays
      networkmanagerapplet

      upkgs.lunar-client
      prismlauncher
      r2modman
      jdk25
      heroic

      dbeaver-bin
      arduino-ide
      simulide
      jetbrains.rider
      inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop
    ];

    # Reload system units when switching config
    systemd.user.startServices = "sd-switch";

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };

}
