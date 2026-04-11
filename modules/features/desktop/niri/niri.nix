{ self, inputs, ... }: {

  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };

    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia
      pkgs.qt6.qtwayland
      pkgs.playerctl
      pkgs.brightnessctl
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

  perSystem = { pkgs, system, lib, self', ... }:
    let upkgs = import inputs.nixpkgs-unstable { inherit system; };
    in {
      packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
        pkgs = upkgs;
        settings = {

          spawn-at-startup = [ (lib.getExe self'.packages.noctalia) ];

          layout = {
            gaps = 5;
            border.width = 0;
            focus-ring = { width = 0; };
          };

          window-rules = [{
            geometry-corner-radius = 12;
            clip-to-geometry = true;
          }];

          input = {
            keyboard.xkb = {
              layout = "us,fr";
              options = "grp:ctrl_alt_toggle";
            };
            touchpad = {
              tap = { };
              natural-scroll = { };
            };
          };
          outputs."eDP-1" = { scale = 1.0; };

          binds = {
            "Mod+Return".spawn = [ "alacritty" ];
            "Mod+Shift+Return".spawn = [ "firefox" ];
            "Mod+Shift+F".spawn = [ "nautilus" ];

            "Mod+D".spawn = [
              "sh"
              "-c"
              "${lib.getExe self'.packages.noctalia} ipc call launcher toggle"
            ];

            "Mod+Shift+Q".close-window = null;
            "Mod+Shift+R".spawn = [ "reboot" ];
            "Mod+Shift+P".spawn = [ "shutdown" "-h" "now" ];
            "Mod+Escape".spawn =
              [ "noctalia-shell" "ipc" "call" "lockscreen" "lock" ];
            "Mod+Shift+N".quit = null;

            "Mod+Shift+Space".toggle-window-floating = null;
            "Mod+F".fullscreen-window = null;

            "Mod+H".focus-column-left = null;
            "Mod+L".focus-column-right = null;
            "Mod+K".focus-window-up = null;
            "Mod+J".focus-window-down = null;

            "Mod+Shift+H".move-column-left = null;
            "Mod+Shift+L".move-column-right = null;
            "Mod+Shift+K".move-window-up = null;
            "Mod+Shift+J".move-window-down = null;

            "Mod+1".focus-workspace = 1;
            "Mod+2".focus-workspace = 2;
            "Mod+3".focus-workspace = 3;
            "Mod+4".focus-workspace = 4;
            "Mod+5".focus-workspace = 5;
            "Mod+6".focus-workspace = 6;
            "Mod+7".focus-workspace = 7;
            "Mod+8".focus-workspace = 8;
            "Mod+9".focus-workspace = 9;

            "Mod+Shift+1".move-column-to-workspace = 1;
            "Mod+Shift+2".move-column-to-workspace = 2;
            "Mod+Shift+3".move-column-to-workspace = 3;
            "Mod+Shift+4".move-column-to-workspace = 4;
            "Mod+Shift+5".move-column-to-workspace = 5;
            "Mod+Shift+6".move-column-to-workspace = 6;
            "Mod+Shift+7".move-column-to-workspace = 7;
            "Mod+Shift+8".move-column-to-workspace = 8;
            "Mod+Shift+9".move-column-to-workspace = 9;

            "Mod+Ctrl+H".set-column-width = "-10%";
            "Mod+Ctrl+L".set-column-width = "+10%";
            "Mod+Ctrl+K".set-window-height = "-10%";
            "Mod+Ctrl+J".set-window-height = "+10%";

            "XF86AudioNext".spawn = [ "playerctl" "next" ];
            "XF86AudioPrev".spawn = [ "playerctl" "previous" ];
            "XF86AudioPlay".spawn = [ "playerctl" "play-pause" ];
            "XF86AudioRaiseVolume".spawn =
              [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+" ];
            "XF86AudioLowerVolume".spawn =
              [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-" ];
            "XF86AudioMute".spawn =
              [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
            "XF86MonBrightnessUp".spawn = [ "brightnessctl" "s" "5%+" ];
            "XF86MonBrightnessDown".spawn = [ "brightnessctl" "s" "5%-" ];

            "Print".spawn = [
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
