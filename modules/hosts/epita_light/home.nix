{ self, inputs, ... }:
{

  flake.homeModules.epitaLightHome =
    { config, pkgs, ... }:
    {
      imports = [
        self.homeModules.i3
        self.homeModules.vim
        self.homeModules.sh
        self.homeModules.git

        self.homeModules.options
        self.homeModules.identity
        self.homeModules.locale
      ];

      config = {
        isSchoolProfile = true;
        isLightProfile = true;

        identity = {
          name = "Kristen Couty";
          email = "kristen.couty@epita.fr";
          signingKey = "${config.home.homeDirectory}/.ssh/epita.pub";
        };

        # General informations
        home.username = "kristen.couty";
        home.homeDirectory = "/home/kristen.couty";
        home.stateVersion = "25.11";

        xsession.windowManager.i3.config.bars = [ ];

        programs.vim.defaultEditor = true;

        # Let Home Manager install and manage itself.
        programs.home-manager.enable = true;
      };
    };
}
