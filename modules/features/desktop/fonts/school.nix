{ self, inputs, ... }:
{

  flake.homeModules.fontsSchool =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        noto-fonts
        noto-fonts-color-emoji
        nerd-fonts.caskaydia-cove
      ];

      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [ "Noto Serif" ];
          sansSerif = [ "Noto Sans" ];
          monospace = [ "CaskaydiaCoveNerdFont" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
}
