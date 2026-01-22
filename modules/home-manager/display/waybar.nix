{ pkgs, lib, config, ... }:

let
  makoctlExe = "${pkgs.mako}/bin/makoctl";
  pavucontrolExe = "${pkgs.pavucontrol}/bin/pavucontrol";
  waybarExe = "${pkgs.waybar}/bin/waybar";
  pkillExe = "${pkgs.procps}/bin/pkill";
  bluemanExe = "${pkgs.blueman}/bin/blueman-manager";

  themeDark = ''
    @define-color base00 #1e2127;
    @define-color base03 #353b45;
    @define-color base05 #abb2bf;
    @define-color base07 #dcdfe4;
    @define-color base08 #e06c75;
    @define-color base09 #d19a66;
    @define-color base0B #98c379;
    @define-color base0C #56b6c2;
    @define-color base0D #61afef;
    @define-color base0E #c678dd;
  '';

  themeLight = ''
    @define-color base00 #fafafa;
    @define-color base03 #e5e5e6;
    @define-color base05 #383a42;
    @define-color base07 #52556d;
    @define-color base08 #e45649;
    @define-color base09 #986801;
    @define-color base0B #50a14f;
    @define-color base0C #0184bc;
    @define-color base0D #4078f2;
    @define-color base0E #a626a4;
  '';

  modules-settings = {
    "sway/workspaces" = {
      disable-scroll = true;
      format = "{name} {icon}";
      format-icons = {
        default = "●";
        "1" = " ";
        "2" = " ";
        "3" = " ";
        "4" = " ";
        "9" = " ";
        "10" = " ";
      };
    };

    "group/misc" = {
      orientation = "inherit";
      modules = [ "custom/notifications" "tray" "idle_inhibitor" ];
      drawer = {
        transition-duration = 250;
        transition-left-to-right = false;
      };
    };

    "custom/notifications" = {
      format = "{icon}";
      format-icons = {
        normal = " ";
        dnd = " ";
      };
      tooltip = false;
      interval = 5;
      return-type = "json";
      exec = ''
        MODE=$(${makoctlExe} mode 2>/dev/null || echo "default")
        if echo "$MODE" | grep -q "dnd"; then
          echo '{"alt":"dnd", "class":"dnd"}'
        else
          echo '{"alt":"normal", "class":"normal"}'
        fi
      '';
      on-click = "${makoctlExe} mode -t dnd && ${pkillExe} -SIGRTMIN+10 waybar";
      signal = 10;
    };

    idle_inhibitor = {
      format = "{icon}";
      format-icons = {
        activated = " ";
        deactivated = " ";
      };
      tooltip = false;
    };

    tray.spacing = 10;

    clock = {
      format = "{:%d %b %H:%M:%S}";
      tooltip-format = ''
        <big>{:%Y %B}</big>
        <tt><small>{calendar}</small></tt>'';
      on-click = "xdg-open https://calendar.google.com/";
    };

    battery = {
      states = {
        good = 95;
        warning = 30;
        critical = 15;
      };

      format-time = "{H}h {M}min";
      format = "{capacity}% {icon}";
      format-alt = "{time} {icon}";
      format-charging = "{capacity}%  ({time})";
      format-plugged = "{capacity}% ";
      format-icons = [ " " " " " " " " " " ];
      tooltip = true;
      tooltip-format = "{timeTo}";
    };

    pulseaudio = {
      scroll-step = 5;
      tooltip = false;
      format = "{volume}% {icon}{format_source}";
      format-bluetooth = "{volume}% {icon}{format_source}";
      format-bluetooth-muted = "<span size='150%'>󰝟</span> {format_source}";
      format-muted = "<span size='150%'>󰝟</span> {format_source}";
      format-source = "";
      format-source-muted = "  ";
      format-icons = {
        headset = " ";
        headphone = " ";
        hands-free = " ";
        phone = " ";
        portable = " ";
        car = " ";
        default = [ "" " " "  " ];
      };
      on-click = "${pavucontrolExe}";
    };

    bluetooth = {
      format = "";
      format-disabled = "";
      format-connected = " {device_alias}";
      format-connected-battery =
        " {device_alias} {device_battery_percentage}%";
      on-click = "${bluemanExe}";
      tooltip = false;
    };

    mpris = {
      format = "{title:.30} - {artist:.30}";
      format-stopped = "";
      tooltip-format = "{album} ({player})";
    };

    cava = {
      bars = 6;
      format-icons = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
      bar_delimiter = 0;
      hide_on_silence = true;
    };

    network = {
      format-wifi = "{essid} ({signalStrength}%)  ";
      format-ethernet = "{ipaddr}/{cidr}  ";
      tooltip-format = "{ifname} via {gwaddr}";
      format-linked = "{ifname} (No IP)  ";
      format-disconnected = "Disconnected <span size='130%'>󰤮</span> ";
      format-alt = "{ifname}: {ipaddr}/{cidr}";
    };
  };
in {
  home.packages = with pkgs; [
    playerctl
    cava
    ripgrep
    pavucontrol
    font-awesome
    procps
    blueman
  ];

  services.playerctld.enable = true;

  xdg.configFile."waybar/colors-dark.css".text = themeDark;
  xdg.configFile."waybar/colors-light.css".text = themeLight;

  home.activation.waybarTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "${config.xdg.configHome}/waybar/colors.css" ]; then
      ln -sf "${config.xdg.configHome}/waybar/colors-dark.css" "${config.xdg.configHome}/waybar/colors.css"
    fi
  '';

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      primary = {
        mode = "hide";
        ipc = true;
        position = "bottom";
        output = [ "eDP-1" ];

        modules-left = [ "sway/workspaces" ];
        modules-center = [ ];
        modules-right = [
          "cava"
          "mpris"
          "bluetooth"
          "pulseaudio"
          "network"
          "battery"
          "clock"
          "group/misc"
        ];
      } // modules-settings;

      additional = {
        mode = "hide";
        ipc = true;
        position = "bottom";
        output =
          [ "DP-1" "DP-2" "DP-3" "DP-4" "HDMI-1" "HDMI-2" "HDMI-3" "HDMI-4" ];

        modules-left = [ "sway/workspaces" ];
        modules-right = [ "network" "clock" "group/misc" ];
      } // modules-settings;
    };

    style = ''
      @import "colors.css";

      * {
        font-family: "CaskaydiaCove Nerd Font", "Font Awesome 6 Free", sans-serif;
        font-size: 13px;
        border-radius: 0;
      }

      #waybar {
        background: alpha(white, 0);
        color: @base00;
      }

      tooltip {
        border-color: @base0D;
        background-color: @base00;
      }
      tooltip label { color: @base05; }

      #workspaces button {
        border-bottom: 3px solid transparent;
        color: @base07;
        background-color: @base03;
      }
      #workspaces button:hover {
        color: @base07;
        background-color: @base03;
      }
      #workspaces button.focused, #workspaces button.active {
        border-bottom: 3px solid @base05;
      }
      #workspaces button.urgent { color: @base08; }

      #tray, #idle_inhibitor, #custom-notifications, #clock {
        background-color: @base03;
      }

      #battery { color: @base00; background-color: @base0B; }
      #battery.charging, #battery.plugged { background-color: @base0B; }
      #battery.warning:not(.charging) { background-color: @base09; }
      #battery.critical:not(.charging) { 
        background-color: @base08; 
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      #pulseaudio { color: @base00; background-color: @base0B; }
      #pulseaudio.muted { background-color: @base09; }

      #bluetooth { color: @base00; background-color: @base0D; } 
      #bluetooth.disconnected { background-color: transparent; }

      #mpris { color: @base00; background-color: @base0E; }

      #mpris.stopped {
        background-color: transparent;
        color: transparent;
        padding: 0;
        margin: 0;
        border: none;
        min-width: 0;
        min-height: 0;
      }

      #cava { color: @base00; background-color: @base0D; }

      #network { color: @base00; background-color: @base0C; }

      .modules-right widget .module {
        padding: 0 .7rem;
        color: @base07;
      }

      #battery, #pulseaudio, #mpris, #cava, #network {
        color: @base00;
      }

      .modules-left > widget:last-child .module,
      .modules-center > widget:last-child .module {
        border-top-right-radius: 5px;
      }
      .modules-center > widget:first-child .module,
      .modules-right > widget:first-child .module {
        border-top-left-radius: 5px;
      }

      #workspaces > button:last-child {
        border-top-right-radius: 5px;
      }

      @keyframes blink {
        to {
          background-color: #ffffff;
          color: #000000;
        }
      }
    '';
  };

  wayland.windowManager.sway.config.bars = [{
    command = "${waybarExe}";
    mode = "hide";
    hiddenState = "hide";
  }];
}
