{ pkgs, ... }:

{
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.caskaydia-cove
    nerd-fonts.caskaydia-mono
    font-awesome
    merriweather
    inter
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Noto Sans" "Merriweather" ];
      sansSerif = [ "Inter" ];
      monospace = [ "CaskaydiaCoveNerdFont" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
