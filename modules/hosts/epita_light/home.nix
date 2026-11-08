{ self, inputs, ... }:
{

  flake.homeModules.epitaLightHome =
    { config, ... }:
    {
      imports = [
        self.homeModules.i3
        self.homeModules.helixSchool
        self.homeModules.wakatime
        self.homeModules.secrets
        self.homeModules.ssh
        self.homeModules.shSchool
        self.homeModules.alacrittySchool
        self.homeModules.gitSchool
        self.homeModules.fontsSchool

        self.homeModules.options
        self.homeModules.identity
        self.homeModules.locale
      ];

      config = {
        useHelixCache = true;

        identity = {
          name = "Kristen Couty";
          email = "kristen.couty@epita.fr";
          signingKey = "${config.home.homeDirectory}/.ssh/epita.pub";
        };

        home.username = "kristen.couty";
        home.homeDirectory = "/home/kristen.couty";
        home.stateVersion = "26.05";

        programs.i3status.enable = true;

        programs.home-manager.enable = true;

        manual.manpages.enable = false;
      };
    };
}
