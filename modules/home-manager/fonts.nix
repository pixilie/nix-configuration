{ pkgs, ... }:

{
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    font-awesome
    merriweather
  ];

  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      serif = [ "Noto Sans" ];
      sansSerif = [ "Merriweather" ];
      monospace = [ "JetBrainsMono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
