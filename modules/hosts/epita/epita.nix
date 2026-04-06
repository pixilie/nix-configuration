{ self, inputs, ... }:
{

  flake.homeModules.epitaHome =
    { config, pkgs, ... }:
    {
      imports = [
        self.homeModules.i3
        self.homeModules.rofi
        self.homeModules.i3bar

        self.homeModules.git
        self.homeModules.helix
        self.homeModules.sh
        self.homeModules.fonts
        self.homeModules.options
      ];

      config = {
        useHelixCache = true;
        isSchoolProfile = true;

        # General informations
        home.username = "kristen.couty";
        home.homeDirectory = "/home/kristen.couty";
        home.stateVersion = "25.11";

        # Packages
        home.packages = with pkgs; [
          nautilus
          spotify
        ];

        # Let Home Manager install and manage itself.
        programs.home-manager.enable = true;
      };
    };
}
