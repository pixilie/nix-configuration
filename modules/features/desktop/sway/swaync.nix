{ self, inputs, ... }: {

  flake.homeModules.swaync =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      swayncClientExe = "${config.services.swaync.package}/bin/swaync-client";

      themeDark = ''
        :root {
          --cc-bg: #1e2127;
          --noti-bg: 23, 25, 30;
          --noti-bg-alpha: 1;
          --noti-bg-darker: #1e2127;
          --noti-bg-hover: #282b31;
          --noti-bg-focus: rgba(53, 59, 69, 0.6);
          --noti-border-color: #353b45;
          --noti-close-bg: #353b45;
          --noti-close-bg-hover: #3e4451;
          --noti-critical: #e06c75;
          --text-color: #abb2bf;
          --text-color-disabled: #5c6370;
          --bg-selected: #61afef;
          --mpris-album-art-overlay: rgba(23, 25, 30, 0.6);
          --mpris-button-hover: rgba(53, 59, 69, 0.8);
        }
      '';

      themeLight = ''
        :root {
          --cc-bg: #f0f0f1;
          --noti-bg: 250, 250, 250;
          --noti-bg-alpha: 1;
          --noti-bg-darker: #f0f0f1;
          --noti-bg-hover: #e5e5e6;
          --noti-bg-focus: rgba(229, 229, 230, 0.6);
          --noti-border-color: #e5e5e6;
          --noti-close-bg: #e5e5e6;
          --noti-close-bg-hover: #dbdbdc;
          --noti-critical: #e45649;
          --text-color: #383a42;
          --text-color-disabled: #a0a1a7;
          --bg-selected: #4078f2;
          --mpris-album-art-overlay: rgba(250, 250, 250, 0.6);
          --mpris-button-hover: rgba(229, 229, 230, 0.8);
          --notification-shadow: 0 0 0 1px rgba(0, 0, 0, 0.06), 0 1px 3px rgba(0, 0, 0, 0.12);
        }
      '';
    in
    {
      xdg.configFile."swaync/colors-dark.css".text = themeDark;
      xdg.configFile."swaync/colors-light.css".text = themeLight;

      home.activation.swayncTheme = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        swayncDir="${config.xdg.configHome}/swaync"
        run mkdir -p "$swayncDir"
        if [ ! -e "$swayncDir/colors.css" ]; then
          run ln -sfn "$swayncDir/colors-dark.css" "$swayncDir/colors.css"
        fi
      '';

      services.swaync = {
        enable = true;
        package = pkgs.swaynotificationcenter.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./swaync-mpris-playing-only.patch ];
        });

        settings = {
          timeout = 5;

          widgets = [
            "title"
            "mpris"
            "dnd"
            "notifications"
          ];

          widget-config.mpris = {
            autohide = true;
            blacklist = [ "playerctld" ];
          };
        };

        style = ''
          @import url("colors.css");

          * { font-family: "Noto Sans"; }

          .notification-row .notification-background .notification.critical { border-color: var(--noti-critical); }
        '';
      };

      wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
        "Mod4+n" = "exec ${swayncClientExe} --toggle-panel --skip-wait";
        "Mod4+Shift+z" = "exec ${swayncClientExe} --hide-latest";
      };
    };
}
