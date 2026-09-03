{ self, inputs, ... }:
{

  flake.homeModules.fonts =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        noto-fonts
        noto-fonts-color-emoji
        nerd-fonts.caskaydia-cove
        font-awesome
        cantarell-fonts
        merriweather
        inter
      ];

      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [
            "Noto Serif"
            "Merriweather"
          ];
          sansSerif = [ "Inter" ];
          monospace = [ "CaskaydiaCoveNerdFont" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
}
