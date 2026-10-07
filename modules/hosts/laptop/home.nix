{ self, inputs, ... }: {

  flake.homeModules.laptopHome =
    {
      config,
      pkgs,
      upkgs,
      ...
    }:
    {
      imports = [
        self.homeModules.gtk
        self.homeModules.darkmanSway
        self.homeModules.sway
        self.homeModules.sway_osd
        self.homeModules.veila
        self.homeModules.mako
        self.homeModules.waybar
        self.homeModules.vicinae

        self.homeModules.gammastep

        self.homeModules.git
        self.homeModules.helix
        self.homeModules.vim
        self.homeModules.zed
        self.homeModules.wakatime
        self.homeModules.secrets
        self.homeModules.sh
        self.homeModules.alacritty
        self.homeModules.fonts
        self.homeModules.tools
        self.homeModules.xdg
        self.homeModules.ssh
        self.homeModules.firefox
        self.homeModules.thunderbird

        self.homeModules.options
        self.homeModules.identity
        self.homeModules.specialPackages
      ];

      config = {
        useHelixCache = true;
        isSchoolProfile = false;

        identity = {
          name = "Kristen Couty";
          email = "kristen.couty@gmail.com";
        };

        home.username = "kristen";
        home.homeDirectory = "/home/kristen";
        home.stateVersion = "26.05";

        home.packages = with pkgs; [
          discord
          spotify
          bitwarden-desktop
          nautilus
          gimp-with-plugins
          onlyoffice-desktopeditors
          obs-studio
          localsend
          gnome-calculator

          zotero
          baobab
          vlc
          image-roll
          pavucontrol
          wdisplays
          networkmanagerapplet

          lunar-client
          prismlauncher
          r2modman
          jdk25
          heroic

          gns3-gui
          gns3-server
          wireshark-cli
        ];

        systemd.user.startServices = "sd-switch";

        programs.home-manager.enable = true;
      };
    };
}
