{ pkgs, lib, ... }:
let
  modifier = "Mod4";
  terminal = "alacritty";
  up = "k";
  down = "j";
  left = "h";
  right = "l";
in {
  imports = [
    ./swaylock.nix
    ./waybar.nix
    ./rofi.nix
    ./mako.nix
    ./darkman.nix
    ./gammastep.nix
    ./gtk.nix
    ./sway_osd.nix
  ];

  home.packages = with pkgs; [
    swaylock-effects
    swaybg
    playerctl
    brightnessctl
    notify-desktop
    grim
    slurp
    satty
    wlroots
  ];

  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;

    config = {
      modifier = "${modifier}";
      terminal = "${terminal}";
      up = "${up}";
      down = "${down}";
      left = "${left}";
      right = "${right}";
      defaultWorkspace = "workspace 1";

      fonts = {
        names = [ "Noto Sans" ];
        size = 12.0;
      };

      window = {
        titlebar = false;
        border = 0;
        commands = [
          {
            criteria.all = true;
            command = "inhibit_idle fullscreen";
          }
          {
            criteria = {
              title = "^((?!^Unity - ).)*$";
              class = "^Unity$";
              instance = "^Unity$";
            };
            command = "floating enable";
          }

        ];
      };

      gaps.smartGaps = false;

      keybindings = lib.mkOptionDefault {
        # Basics keys
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+Shift+q" = "kill";
        "${modifier}+Shift+Return" = "exec firefox";
        "${modifier}+Shift+r" = "exec reboot";
        "${modifier}+Shift+p" = "exec shutdown -h now";
        "${modifier}+Escape" =
          "exec sleep 0.3 && swaylock -C ~/.config/swaylock/config";
        "${modifier}" = "exec swaymsg bar mode toggle";
        "${modifier}+Shift+s" =
          "exec ${pkgs.swaylock-effects}/bin/swaylock -f -C ~/.config/swaylock/config && systemctl suspend";
        "${modifier}+Shift+n" = "swaymsg exit";
        "${modifier}+Shift+z" = "exec makoctl dismiss";
        "${modifier}+Shift+f" = "exec nautilus";

        # Movements keys
        "${modifier}+${left}" = "focus left";
        "${modifier}+${right}" = "focus right";
        "${modifier}+${up}" = "focus up";
        "${modifier}+${down}" = "focus down";

        # Workspace related keys
        "${modifier}+1" = "workspace 1";
        "${modifier}+2" = "workspace 2";
        "${modifier}+3" = "workspace 3";
        "${modifier}+4" = "workspace 4";
        "${modifier}+5" = "workspace 5";
        "${modifier}+6" = "workspace 6";
        "${modifier}+7" = "workspace 7";
        "${modifier}+8" = "workspace 8";
        "${modifier}+9" = "workspace 9";
        "${modifier}+0" = "workspace 10";

        "${modifier}+Shift+1" = "move container to workspace 1";
        "${modifier}+Shift+2" = "move container to workspace 2";
        "${modifier}+Shift+3" = "move container to workspace 3";
        "${modifier}+Shift+4" = "move container to workspace 4";
        "${modifier}+Shift+5" = "move container to workspace 5";
        "${modifier}+Shift+6" = "move container to workspace 6";
        "${modifier}+Shift+7" = "move container to workspace 7";
        "${modifier}+Shift+8" = "move container to workspace 8";
        "${modifier}+Shift+9" = "move container to workspace 9";
        "${modifier}+Shift+0" = "move container to workspace 10";

        # Switch to resize mode
        "${modifier}+r" = "mode resize";

        # Control keys
        "XF86AudioNext" = "exec swayosd-client --playerctl next";
        "XF86AudioPrev" = "exec swayosd-client --playerctl previous";
        "XF86AudioPlay" = "exec swayosd-client --playerctl play-pause";

        "XF86AudioRaiseVolume" = "exec swayosd-client --output-volume raise";
        "XF86AudioLowerVolume" = "exec swayosd-client --output-volume lower";
        "XF86AudioMute" = "exec swayosd-client --output-volume mute-toggle";

        "XF86MonBrightnessUp" = "exec swayosd-client --brightness raise";
        "XF86MonBrightnessDown" = "exec swayosd-client --brightness lower";

        "Caps_Lock" = "exec swayosd-client --caps-lock";

        "Print" = ''
          exec grim -g "$(slurp)" - | satty -f - --action-on-enter save-to-clipboard'';
      };

      # Resize mode
      modes = {
        resize = {
          "${left}" = "resize shrink width 10 px";
          "${right}" = "resize grow width 10 px";
          "${up}" = "resize shrink height 10 px";
          "${down}" = "resize grow height 10 px";
          "Escape" = "mode default";
        };
      };

      input = {
        "type:touchpad" = {
          tap = "enabled";
          tap_button_map = "lrm";
          click_method = "clickfinger";
          scroll_method = "two_finger";
          natural_scroll = "enabled";
          dwt = "disabled";
        };

        "type:keyboard" = {
          xkb_layout = "us,fr";
          xkb_options = "grp:ctrl_alt_toggle";
        };
      };

      output = {
        "eDP-1" = {
          resolution = "1920x1080";
          scale = "1.0";
          pos = "0 0";
        };
      };

      startup =
        [{ command = "${pkgs.geoclue2}/libexec/geoclue-2.0/demos/agent"; }];

    };

    extraConfig = ''
      exec dbus-update-activation-environment --systemd --all
    '';
  };

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 175;
        command =
          "${pkgs.notify-desktop}/bin/notify-desktop 'Screen locking in 5 seconds'";
      }
      {
        timeout = 179;
        command = "${pkgs.playerctl}/bin/playerctl pause";
      }
      {
        timeout = 180;
        command = "${pkgs.swaylock-effects}/bin/swaylock";
      }
      {
        timeout = 190;
        command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
      }
      {
        timeout = 300;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };

  services.poweralertd.enable = true;
}
