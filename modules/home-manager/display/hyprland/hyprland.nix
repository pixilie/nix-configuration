{ pkgs, ... }:

{
  imports = [ ./anyrun.nix ./eww.nix ];
  programs.kitty.enable = true;

  home.packages = with pkgs; [
    anyrun
    hyprpaper
    # hyprlauncher
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
    enable = true;

    settings = {
      exec-once = [
        "eww daemon && eww open bar"
        "swaync"
      ];

      monitor = ",preferred,auto,1";

      input = {
        kb_layout = "fr";
        follow_mouse = 1;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" =
          "rgba(cba6f7ff) rgba(89b4faff) 45deg";
        "col.inactive_border" = "rgba(1e1e2eaa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      "$mod" = "SUPER";
      "$terminal" = "alacritty";
      "$menu" = "anyrun";

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, Space, exec, $menu"

        "$mod, Shift, Q, killactive,"
        "$mod, V, togglefloating,"
        "$mod, F, fullscreen,"

        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
      ];
    };
  };
}
