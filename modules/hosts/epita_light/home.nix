{ self, inputs, ... }:
{

  flake.homeModules.epitaLightHome =
    { config, ... }:
    {
      imports = [
        self.homeModules.i3
        self.homeModules.vim
        self.homeModules.helix
        self.homeModules.wakatime
        self.homeModules.secrets
        self.homeModules.sh
        self.homeModules.git
        self.homeModules.fonts

        self.homeModules.options
        self.homeModules.identity
        self.homeModules.locale
      ];

      config = {
        useHelixCache = true;
        isSchoolProfile = true;
        isLightProfile = true;

        secrets.identityFile = "${config.home.homeDirectory}/.ssh/epita";

        identity = {
          name = "Kristen Couty";
          email = "kristen.couty@epita.fr";
          signingKey = "${config.home.homeDirectory}/.ssh/epita.pub";
        };

        # General informations
        home.username = "kristen.couty";
        home.homeDirectory = "/home/kristen.couty";
        home.stateVersion = "26.05";

        programs.i3status.enable = true;

        programs.vim.defaultEditor = true;

        # Let Home Manager install and manage itself.
        programs.home-manager.enable = true;
      };
    };
}
