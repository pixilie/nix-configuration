{ pkgs, ... }:

{
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    # nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.caskaydia-mono
    font-awesome
    merriweather
    inter
    monocraft
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
