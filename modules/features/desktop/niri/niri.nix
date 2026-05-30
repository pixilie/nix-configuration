{ self, inputs, ... }: {

  flake.nixosModules.niri = { pkgs, lib, ... }: {
    imports = [ inputs.niri.nixosModules.niri ];

    programs.niri.enable = true;
    programs.dconf.enable = true;
    services.gvfs.enable = true;

    environment.systemPackages = [
      pkgs.qt6.qtwayland
      pkgs.playerctl
      pkgs.brightnessctl
      pkgs.xwayland-satellite
    ];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      GDK_BACKEND = "wayland";
      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = "";
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals =
        [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-gnome ];
      config = { common.default = [ "gnome" "*" ]; };
    };
  };

  flake.homeModules.niri = { pkgs, lib, config, ... }: {
    imports = [ inputs.niri.homeModules.niri ];

    home.packages = with pkgs; [ swaybg notify-desktop grim slurp satty ];

    programs.niri = {
      enable = true;

      settings = {
        prefer-no-csd = true;

        spawn-at-startup = [
          {
            command = [
              "systemctl"
              "--user"
              "import-environment"
              "WAYLAND_DISPLAY"
              "XDG_CURRENT_DESKTOP"
              "SSH_AUTH_SOCK"
            ];
          }
          {
            command = [ "${lib.getExe pkgs.valent}" "--gapplication-service" ];
          }
          { command = [ "${pkgs.geoclue2}/libexec/geoclue-2.0/demos/agent" ]; }
        ];

        layout = {
          gaps = 5;
          border.width = 0;
          focus-ring.width = 0;
        };

        input = {
          keyboard.xkb = {
            layout = "us,fr";
            options = "grp:ctrl_alt_toggle";
          };
          touchpad = {
            tap = true;
            natural-scroll = true;
          };
        };

        outputs."eDP-1" = { scale = 1.0; };

        binds = {
          "Mod+Return".action.spawn = "alacritty";
          "Mod+Shift+Q".action.close-window = [ ];
          "Mod+Shift+Return".action.spawn = "firefox";

          "Mod+Shift+R".action.spawn = "reboot";
          "Mod+Shift+P".action.spawn = [ "shutdown" "-h" "now" ];
          "Mod+Escape".action.spawn =
            [ "sh" "-c" "sleep 0.3 && swaylock -C ~/.config/swaylock/config" ];
          "Mod+Shift+S".action.spawn = [
            "sh"
            "-c"
            "${pkgs.swaylock-effects}/bin/swaylock -f -C ~/.config/swaylock/config && systemctl suspend"
          ];
          "Mod+Shift+N".action.quit = [ ];
          "Mod+Shift+Z".action.spawn = [ "makoctl" "dismiss" ];
          "Mod+Shift+F".action.spawn = "nautilus";

          "Mod+D".action.spawn = "fuzzel";

          "Mod+Space".action.toggle-window-floating = [ ];
          "Mod+F".action.fullscreen-window = [ ];

          "Mod+H".action.focus-column-left = [ ];
          "Mod+L".action.focus-column-right = [ ];
          "Mod+K".action.focus-window-up = [ ];
          "Mod+J".action.focus-window-down = [ ];

          "Mod+Shift+H".action.move-column-left = [ ];
          "Mod+Shift+L".action.move-column-right = [ ];
          "Mod+Shift+K".action.move-window-up = [ ];
          "Mod+Shift+J".action.move-window-down = [ ];

          "Mod+1".action.focus-workspace = 1;
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;
          "Mod+6".action.focus-workspace = 6;
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;
          "Mod+9".action.focus-workspace = 9;

          "Mod+Shift+1".action.move-column-to-workspace = 1;
          "Mod+Shift+2".action.move-column-to-workspace = 2;
          "Mod+Shift+3".action.move-column-to-workspace = 3;
          "Mod+Shift+4".action.move-column-to-workspace = 4;
          "Mod+Shift+5".action.move-column-to-workspace = 5;
          "Mod+Shift+6".action.move-column-to-workspace = 6;
          "Mod+Shift+7".action.move-column-to-workspace = 7;
          "Mod+Shift+8".action.move-column-to-workspace = 8;
          "Mod+Shift+9".action.move-column-to-workspace = 9;

          "Mod+Ctrl+H".action.set-column-width = "-10%";
          "Mod+Ctrl+L".action.set-column-width = "+10%";
          "Mod+Ctrl+K".action.set-window-height = "-10%";
          "Mod+Ctrl+J".action.set-window-height = "+10%";

          "XF86AudioNext".action.spawn = [ "playerctl" "next" ];
          "XF86AudioPrev".action.spawn = [ "playerctl" "previous" ];
          "XF86AudioPlay".action.spawn = [ "playerctl" "play-pause" ];
          "XF86AudioRaiseVolume".action.spawn =
            [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+" ];
          "XF86AudioLowerVolume".action.spawn =
            [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-" ];
          "XF86AudioMute".action.spawn =
            [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
          "XF86MonBrightnessUp".action.spawn = [ "brightnessctl" "s" "5%+" ];
          "XF86MonBrightnessDown".action.spawn = [ "brightnessctl" "s" "5%-" ];

          "Print".action.spawn = [
            "sh"
            "-c"
            ''
              grim -g "$(slurp)" - | satty -f - --action-on-enter save-to-clipboard''
          ];
        };
      };
    };
  };
}
