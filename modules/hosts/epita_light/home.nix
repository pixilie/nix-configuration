{ self, inputs, ... }:
{

  flake.homeModules.epitaLightHome =
    { config, pkgs, ... }:
    {
      imports = [
        self.homeModules.i3
        self.homeModules.vim
        self.homeModules.sh

        self.homeModules.options
      ];

      config = {
        isSchoolProfile = true;
        isLightProfile = true;

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
