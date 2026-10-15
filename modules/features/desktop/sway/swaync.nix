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
      nmcliExe = lib.getExe' pkgs.networkmanager "nmcli";
      bluetoothctlExe = lib.getExe' pkgs.bluez "bluetoothctl";
      rfkillExe = lib.getExe' pkgs.util-linux "rfkill";
      wpctlExe = lib.getExe' pkgs.wireplumber "wpctl";
      systemctlExe = lib.getExe' pkgs.systemd "systemctl";
      grepExe = lib.getExe pkgs.gnugrep;
      darkmanExe = lib.getExe pkgs.darkman;

      toggle = name: label: on: off: isOn: {
        inherit label;
        type = "toggle";
        command = "${pkgs.writeShellScript "swaync-${name}-toggle" ''
          if [ "$SWAYNC_TOGGLE_STATE" = true ]; then
            ${on}
          else
            ${off}
          fi
        ''}";
        update-command = "${pkgs.writeShellScript "swaync-${name}-state" ''
          if ${isOn}; then echo true; else echo false; fi
        ''}";
      };

      closePanelThen =
        name: script:
        "${pkgs.writeShellScript "swaync-${name}" ''
          ${swayncClientExe} --close-panel
          ${pkgs.coreutils}/bin/sleep 0.3
          ${script}
        ''}";

      action = name: label: script: {
        inherit label;
        command = closePanelThen name script;
      };

      themeDark = ''
        :root {
          --cc-bg: #1e2127;
          --noti-bg: 40, 44, 52;
          --noti-bg-alpha: 1;
          --noti-bg-darker: #21252b;
          --noti-bg-hover: #2c313a;
          --noti-border-color: #353b45;
          --noti-close-bg: #353b45;
          --noti-close-bg-hover: #3e4451;
          --noti-critical: #e06c75;
          --text-color: #abb2bf;
          --text-color-secondary: #8b92a0;
          --text-color-disabled: #5c6370;
          --bg-selected: #61afef;
          --accent-fg: #1e2127;
          --tile-bg: #282c34;
          --tile-bg-hover: #323842;
          --popup-shadow: 0 2px 8px rgba(0, 0, 0, 0.35);
          --mpris-album-art-overlay: rgba(30, 33, 39, 0.65);
          --mpris-button-hover: rgba(53, 59, 69, 0.8);
        }
      '';

      themeLight = ''
        :root {
          --cc-bg: #f0f0f1;
          --noti-bg: 255, 255, 255;
          --noti-bg-alpha: 1;
          --noti-bg-darker: #f0f0f1;
          --noti-bg-hover: #f5f5f6;
          --noti-border-color: #dcdce0;
          --noti-close-bg: #e5e5e6;
          --noti-close-bg-hover: #dbdbdc;
          --noti-critical: #e45649;
          --text-color: #383a42;
          --text-color-secondary: #696c77;
          --text-color-disabled: #a0a1a7;
          --bg-selected: #4078f2;
          --accent-fg: #ffffff;
          --tile-bg: #ffffff;
          --tile-bg-hover: #f5f5f6;
          --popup-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
          --mpris-album-art-overlay: rgba(250, 250, 250, 0.7);
          --mpris-button-hover: rgba(229, 229, 230, 0.8);
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
          patches = (old.patches or [ ]) ++ [
            ./swaync-mpris-hide-idle-players.patch
            ./swaync-volume-label-command.patch
          ];
        });

        settings = {
          timeout = 5;
          notification-window-width = 560;
          control-center-width = 470;
          control-center-margin-top = 10;
          control-center-margin-bottom = 10;
          control-center-margin-right = 10;

          widgets = [
            "title"
            "mpris"
            "notifications"
            "volume"
            "buttons-grid"
          ];

          widget-config = {
            mpris = {
              autohide = true;
              blacklist = [ "playerctld" ];
            };

            volume = {
              label = "󰕾";
              label-command = closePanelThen "mixer" (lib.getExe pkgs.pavucontrol);
            };

            buttons-grid = {
              buttons-per-row = 8;
              actions = [
                (toggle "wifi" "󰖩" "${nmcliExe} radio wifi on" "${nmcliExe} radio wifi off"
                  ''[ "$(${nmcliExe} radio wifi)" = enabled ]''
                )
                (toggle "bluetooth" "󰂯" "${rfkillExe} unblock bluetooth; ${bluetoothctlExe} power on"
                  "${bluetoothctlExe} power off"
                  "${bluetoothctlExe} show | ${grepExe} -q 'Powered: yes'"
                )
                (toggle "mic" "󰍬" "${wpctlExe} set-mute @DEFAULT_AUDIO_SOURCE@ 0"
                  "${wpctlExe} set-mute @DEFAULT_AUDIO_SOURCE@ 1"
                  "! ${wpctlExe} get-volume @DEFAULT_AUDIO_SOURCE@ | ${grepExe} -q MUTED"
                )
                (toggle "dnd" "󰂛" "${swayncClientExe} --dnd-on" "${swayncClientExe} --dnd-off"
                  ''[ "$(${swayncClientExe} --get-dnd)" = true ]''
                )
                (toggle "night-light" "󰖔" "${systemctlExe} --user start gammastep"
                  "${systemctlExe} --user stop gammastep"
                  "${systemctlExe} --user is-active --quiet gammastep"
                )
                (toggle "theme" "󰔎" "${darkmanExe} set dark" "${darkmanExe} set light"
                  ''[ "$(${darkmanExe} get)" = dark ]''
                )
                (action "screenshot" "󰹑"
                  ''${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" - | ${lib.getExe pkgs.satty} -f - --action-on-enter save-to-clipboard''
                )
                (action "lock" "󰌾" "veila-lock")
              ];
            };
          };
        };

        style = ''
          @import url("colors.css");

          * { font-family: "Noto Sans"; }

          :root {
            --border-radius: 8px;
            --notification-icon-size: 44px;
            --notification-group-icon-size: 20px;
            --font-size-summary: 14px;
            --font-size-body: 13px;
            --mpris-album-art-icon-size: 64px;
          }

          .control-center {
            border: 1px solid var(--noti-border-color);
            border-radius: 12px;
          }

          .widget-title { margin: 10px 14px 4px; padding: 0; }
          .widget-title > label { font-size: 1.1rem; font-weight: 600; }
          .widget-title > button {
            min-height: 0;
            padding: 4px 12px;
            font-size: 0.85rem;
            border: 1px solid var(--noti-border-color);
            border-radius: 6px;
            box-shadow: none;
            background: var(--tile-bg);
            color: var(--text-color);
          }
          .widget-title > button:hover { background: var(--tile-bg-hover); }

          .notification-group,
          .notification-group:hover,
          .notification-group:focus,
          .notification-group:selected { background: transparent; }
          .notification-group { outline: none; }
          .notification-group:focus-visible .notification-row .notification-background .notification { border-color: var(--bg-selected); }
          .notification-group .notification-group-headers { margin: 6px 14px 0; }
          .notification-group .notification-group-headers .notification-group-header { font-size: 13px; font-weight: 600; color: var(--text-color-secondary); }
          .notification-group .notification-group-buttons { margin: 0 14px; }

          .widget-notifications { margin: 0 4px; padding: 0; }
          .notification-row .notification-background { padding: 4px 10px; }
          .notification-row .notification-background .notification {
            border: 1px solid var(--noti-border-color);
            box-shadow: none;
          }
          .notification-row .notification-background .notification.critical { border-color: var(--noti-critical); }
          .floating-notifications .notification-row .notification-background .notification { box-shadow: var(--popup-shadow); }

          .notification-default-action { padding: 10px 12px; }
          .notification-content .image { border-radius: 8px; margin: 0 12px 0 0; }
          .notification-content .text-box .summary { font-size: var(--font-size-summary); font-weight: 600; }
          .notification-content .text-box .time { font-size: 12px; font-weight: normal; color: var(--text-color-disabled); margin-right: 28px; }
          .notification-content .text-box .body { font-size: var(--font-size-body); color: var(--text-color-secondary); }

          .close-button { min-width: 20px; min-height: 20px; margin-top: 10px; margin-right: 10px; background: var(--noti-close-bg); color: var(--text-color-secondary); }
          .close-button:hover { background: var(--noti-close-bg-hover); color: var(--text-color); }

          .notification-action > button { border: none; border-radius: 6px; box-shadow: none; background: var(--tile-bg); color: var(--text-color); }
          .notification-action > button:hover { background: var(--tile-bg-hover); }

          .widget-mpris { margin: 4px; }
          .widget-mpris .widget-mpris-player { margin: 6px 10px; border: 1px solid var(--noti-border-color); box-shadow: none; }
          .widget-mpris .widget-mpris-player .mpris-overlay { padding: 12px; }
          .widget-mpris .widget-mpris-player .mpris-overlay .widget-mpris-album-art { border-radius: 6px; box-shadow: none; }
          .widget-mpris .widget-mpris-player .mpris-overlay .widget-mpris-title { font-size: 1rem; font-weight: 600; }
          .widget-mpris .widget-mpris-player .mpris-overlay .widget-mpris-subtitle { font-size: 0.9rem; color: var(--text-color-secondary); }

          .widget-volume {
            margin: 6px 14px 2px;
            padding: 6px 12px;
            border: 1px solid var(--noti-border-color);
            border-radius: var(--border-radius);
            background: var(--tile-bg);
          }
          .widget-volume label { font-family: "CaskaydiaCove Nerd Font Propo"; font-size: 20px; }
          .widget-volume label.clickable { padding: 0 4px; border-radius: 6px; }
          .widget-volume label.clickable:hover { color: var(--bg-selected); }
          .widget-volume scale trough { background: var(--noti-border-color); }
          .widget-volume scale highlight { background: var(--bg-selected); }

          .widget-buttons-grid { margin: 2px 10px 12px; padding: 0; }
          .widget-buttons-grid flowboxchild { padding: 0 3px; }
          .widget-buttons-grid flowboxchild > button {
            min-height: 44px;
            min-width: 0;
            padding: 0;
            border: 1px solid var(--noti-border-color);
            border-radius: var(--border-radius);
            box-shadow: none;
            background: var(--tile-bg);
            color: var(--text-color);
          }
          .widget-buttons-grid flowboxchild > button label { font-family: "CaskaydiaCove Nerd Font Propo"; font-size: 20px; }
          .widget-buttons-grid flowboxchild > button:hover { background: var(--tile-bg-hover); }
          .widget-buttons-grid flowboxchild > button.toggle:checked { border-color: var(--bg-selected); background: var(--bg-selected); color: var(--accent-fg); }
        '';
      };

      wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
        "Mod4+n" = "exec ${swayncClientExe} --toggle-panel --skip-wait";
        "Mod4+Shift+z" = "exec ${swayncClientExe} --hide-latest";
      };
    };
}
