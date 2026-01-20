{ pkgs, ... }:

{
  services.darkman = {
    enable = true;
    package = pkgs.darkman;

    settings = {
      usegeoclue = true;
    };

    darkModeScripts = {
      gtk-theme = ''
        ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
      '';
    };

    lightModeScripts = {
      gtk-theme = ''
        ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
      '';
    };
  };
}
