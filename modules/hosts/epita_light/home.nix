{ self, inputs, ... }:
{

  flake.homeModules.epitaLightHome =
    { config, pkgs, ... }:
    {
      imports = [
        self.homeModules.i3
        self.homeModules.helix
        self.homeModules.vim
        self.homeModules.sh
        self.homeModules.git

        self.homeModules.options
        self.homeModules.identity
        self.homeModules.locale
      ];

      config = {
        useHelixCache = true;
        isSchoolProfile = true;
        isLightProfile = true;

        identity = {
          name = "Kristen Couty";
          email = "kristen.couty@epita.fr";
          signingKey = "${config.home.homeDirectory}/.ssh/epita.pub";
        };

        home.packages = with pkgs; [
          wakatime-cli
        ];

        # General informations
        home.username = "kristen.couty";
        home.homeDirectory = "/home/kristen.couty";
        home.stateVersion = "25.11";

        programs.i3status.enable = true;

        programs.vim.defaultEditor = true;

        # Let Home Manager install and manage itself.
        programs.home-manager.enable = true;
      };
    };
}
