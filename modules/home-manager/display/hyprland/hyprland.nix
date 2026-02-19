{ pkgs, ... }:

{

  programs.kitty.enable = true;

  home.packages = with pkgs; [
    hyprpaper
    hyprlauncher
    hypridle
    hyprlock
    hyprsunset
    hyprpwcenter
    hyprcursor
    hyprutils
    hyprgraphics
    hyprpolkitagent
    dunst
  ];

  wayland.windowManager.hyprland = {
    systemd.enable = true;
  };
}
