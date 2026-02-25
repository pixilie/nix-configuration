{ pkgs, ... }:

{
  programs.eww = {
    enable = true;
  };

  xdg.configFile."eww" = {
    source = ./eww-config;
    recursive = true;
  };

  home.packages = with pkgs; [
    socat
    jq
    gcalcli
    swaynotificationcenter
  ];
}
