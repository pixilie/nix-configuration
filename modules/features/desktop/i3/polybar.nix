{ self, inputs, ... }:
{

  flake.homeModules.polybar =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      polybar = pkgs.polybar.override {
        i3Support = true;
        pulseSupport = true;
      };

      polybarExe = "${polybar}/bin/polybar";
      polybarMsgExe = "${polybar}/bin/polybar-msg";
      playerctlExe = "${pkgs.playerctl}/bin/playerctl";
      bluetoothctlExe = "${pkgs.bluez}/bin/bluetoothctl";
      pavucontrolExe = "${pkgs.pavucontrol}/bin/pavucontrol";
      bluemanExe = "${pkgs.blueman}/bin/blueman-manager";
      xdgOpenExe = "${pkgs.xdg-utils}/bin/xdg-open";
      cutExe = "${pkgs.coreutils}/bin/cut";
      headExe = "${pkgs.coreutils}/bin/head";
      sleepExe = "${pkgs.coreutils}/bin/sleep";
      idExe = "${pkgs.coreutils}/bin/id";

      colorsDark = ''
        [colors]
        base00 = #1e2127
        base03 = #353b45
        base05 = #abb2bf
        base07 = #dcdfe4
        base08 = #e06c75
        base09 = #d19a66
        base0B = #98c379
        base0C = #56b6c2
        base0D = #61afef
        base0E = #c678dd
      '';

      colorsLight = ''
        [colors]
        base00 = #fafafa
        base03 = #e5e5e6
        base05 = #383a42
        base07 = #52556d
        base08 = #e45649
        base09 = #986801
        base0B = #50a14f
        base0C = #0184bc
        base0D = #4078f2
        base0E = #a626a4
      '';

      base00 = "\${colors.base00}";
      base03 = "\${colors.base03}";
      base05 = "\${colors.base05}";
      base07 = "\${colors.base07}";
      base08 = "\${colors.base08}";
      base09 = "\${colors.base09}";
      base0B = "\${colors.base0B}";
      base0C = "\${colors.base0C}";
      base0D = "\${colors.base0D}";

      modulePadding = 1;

      mprisScript = pkgs.writeShellScript "polybar-mpris" ''
        status=$(${playerctlExe} status 2>/dev/null) || exit 0
        [ "$status" = "Stopped" ] && exit 0
        ${playerctlExe} metadata --format '{{ title }} - {{ artist }}' 2>/dev/null
        exit 0
      '';

      bluetoothScript = pkgs.writeShellScript "polybar-bluetooth" ''
        ${bluetoothctlExe} show > /dev/null 2>&1 || exit 0
        device=$(${bluetoothctlExe} devices Connected 2>/dev/null \
          | ${headExe} -n 1 | ${cutExe} -d ' ' -f 3-)
        [ -n "$device" ] && echo " $device"
        exit 0
      '';

      hideScript = pkgs.writeShellScript "polybar-hide" ''
        socket="''${XDG_RUNTIME_DIR:-/run/user/$(${idExe} -u)}/polybar/ipc.$1.sock"

        attempts=0
        while [ ! -S "$socket" ] && [ "$attempts" -lt 50 ]; do
          ${sleepExe} 0.1
          attempts=$((attempts + 1))
        done

        ${polybarMsgExe} -p "$1" cmd hide > /dev/null 2>&1
        exit 0
      '';
    in
    {
      home.packages = with pkgs; [
        pavucontrol
        blueman
      ];

      services.playerctld.enable = true;

      xdg.configFile."polybar/colors-dark.ini".text = colorsDark;
      xdg.configFile."polybar/colors-light.ini".text = colorsLight;

      home.activation.ensurePolybarTheme = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        polybarDir="${config.xdg.configHome}/polybar"
        run mkdir -p "$polybarDir"
        if [ ! -e "$polybarDir/colors.ini" ]; then
          run ln -sfn "$polybarDir/colors-dark.ini" "$polybarDir/colors.ini"
        fi
      '';

      services.polybar = {
        enable = true;
        package = polybar;

        script = ''
          ${polybarMsgExe} cmd quit > /dev/null 2>&1 || true

          monitors=$(${polybarExe} --list-monitors | ${cutExe} -d ':' -f 1)

          if [ -z "$monitors" ]; then
            ${polybarExe} --reload main &
            ${hideScript} $! &
          else
            for monitor in $monitors; do
              MONITOR="$monitor" ${polybarExe} --reload main &
              ${hideScript} $! &
            done
          fi
        '';

        extraConfig = ''
          include-file = ${config.xdg.configHome}/polybar/colors.ini
        '';

        settings = {
          settings = {
            pseudo-transparency = true;
          };

          "bar/main" = {
            monitor = "\${env:MONITOR:}";
            bottom = true;
            fixed-center = true;
            width = "100%";
            height = "28px";
            radius = 0;
            enable-ipc = true;
            override-redirect = true;
            enable-struts = false;
            wm-restack = "i3";

            background = "#00000000";
            foreground = base07;
            line-size = "3px";

            padding = 0;
            module-margin = 0;
            separator = "";

            font = [
              "CaskaydiaCove Nerd Font:size=10;2"
              "Noto Sans:size=10;2"
            ];

            modules-left = "i3";
            modules-right = "mpris bluetooth pulseaudio network-wireless network-wired battery date tray";

            cursor-click = "pointer";
          };

          "module/i3" = {
            type = "internal/i3";
            pin-workspaces = true;
            show-urgent = true;
            index-sort = true;
            enable-click = true;
            enable-scroll = false;
            fuzzy-match = true;

            format = "<label-state> <label-mode>";

            ws-icon = [
              "1;"
              "2;"
              "3;"
              "4;"
              "9;"
              "10;󰙯"
            ];
            ws-icon-default = "●";

            label-focused = "%name% %icon%";
            label-focused-background = base03;
            label-focused-foreground = base07;
            label-focused-underline = base05;
            label-focused-padding = 1;

            label-unfocused = "%name% %icon%";
            label-unfocused-background = base03;
            label-unfocused-foreground = base07;
            label-unfocused-padding = 1;

            label-visible = "%name% %icon%";
            label-visible-background = base03;
            label-visible-foreground = base07;
            label-visible-padding = 1;

            label-urgent = "%name% %icon%";
            label-urgent-background = base03;
            label-urgent-foreground = base08;
            label-urgent-padding = 1;

            label-separator = " ";

            label-mode = "%mode%";
            label-mode-background = base09;
            label-mode-foreground = base00;
            label-mode-padding = 1;
          };

          "module/mpris" = {
            type = "custom/script";
            exec = "${mprisScript}";
            interval = 3;

            format = "<label>";
            label = "%output%";
            label-foreground = base07;
            label-padding = modulePadding;
            label-maxlen = 63;

            click-left = "${playerctlExe} play-pause";
            click-right = "${playerctlExe} next";
          };

          "module/bluetooth" = {
            type = "custom/script";
            exec = "${bluetoothScript}";
            interval = 5;

            format = "<label>";
            label = "%output%";
            label-background = base0D;
            label-foreground = base00;
            label-padding = modulePadding;

            click-left = "${bluemanExe}";
          };

          "module/pulseaudio" = {
            type = "internal/pulseaudio";
            interval = 5;
            use-ui-max = false;

            format-volume = "<label-volume> <ramp-volume>";
            format-volume-background = base0B;
            format-volume-foreground = base00;
            format-volume-padding = modulePadding;
            label-volume = "%percentage%%";

            format-muted = "<label-muted>";
            format-muted-background = base09;
            format-muted-foreground = base00;
            format-muted-padding = modulePadding;
            label-muted = "󰝟";

            ramp-volume = [
              ""
              ""
              ""
            ];

            click-right = "${pavucontrolExe}";
          };

          "module/network-wireless" = {
            type = "internal/network";
            interface-type = "wireless";
            interval = 5;

            format-connected = "<label-connected>";
            format-connected-background = base0C;
            format-connected-foreground = base00;
            format-connected-padding = modulePadding;
            label-connected = "%essid% (%signal%%) ";

            format-disconnected = "<label-disconnected>";
            format-disconnected-background = base0C;
            format-disconnected-foreground = base00;
            format-disconnected-padding = modulePadding;
            label-disconnected = "Disconnected 󰤮";
          };

          "module/network-wired" = {
            type = "internal/network";
            interface-type = "wired";
            interval = 5;

            format-connected = "<label-connected>";
            format-connected-background = base0C;
            format-connected-foreground = base00;
            format-connected-padding = modulePadding;
            label-connected = "%local_ip% 󰈀";

            format-disconnected = "<label-disconnected>";
            format-disconnected-background = base0C;
            format-disconnected-foreground = base00;
            format-disconnected-padding = modulePadding;
            label-disconnected = "Disconnected 󰤮";
          };

          "module/battery" = {
            type = "internal/battery";
            battery = "BAT0";
            adapter = "AC";
            full-at = 99;
            low-at = 15;
            poll-interval = 5;
            time-format = "%Hh %Mmin";

            format-discharging = "<label-discharging> <ramp-capacity>";
            format-discharging-background = base0B;
            format-discharging-foreground = base00;
            format-discharging-padding = modulePadding;
            label-discharging = "%percentage%%";

            format-charging = "<label-charging>";
            format-charging-background = base0B;
            format-charging-foreground = base00;
            format-charging-padding = modulePadding;
            label-charging = "%percentage%%  (%time%)";

            format-full = "<label-full>";
            format-full-background = base0B;
            format-full-foreground = base00;
            format-full-padding = modulePadding;
            label-full = "%percentage%% ";

            format-low = "<label-low> <ramp-capacity>";
            format-low-background = base08;
            format-low-foreground = base00;
            format-low-padding = modulePadding;
            label-low = "%percentage%%";

            ramp-capacity = [
              ""
              ""
              ""
              ""
              ""
            ];
          };

          "module/date" = {
            type = "internal/date";
            interval = 1;

            date = "%d %b";
            time = "%H:%M:%S";

            format = "<label>";
            format-background = base03;
            format-foreground = base07;
            format-padding = modulePadding;
            label = "%date% %time%";

            click-left = "${xdgOpenExe} https://calendar.google.com/";
          };

          "module/tray" = {
            type = "internal/tray";
            format = "<tray>";
            format-background = base03;
            tray-background = base03;
            tray-foreground = base07;
            tray-spacing = "10px";
            tray-padding = "6px";
            tray-size = "66%";
          };
        };
      };

      xsession.windowManager.i3.config = {
        bars = [ ];

        startup = [
          {
            command = "systemctl --user import-environment DISPLAY XAUTHORITY && systemctl --user restart polybar.service";
            always = true;
            notification = false;
          }
        ];

        keybindings = lib.mkOptionDefault {
          "Super_L" = "exec --no-startup-id ${polybarMsgExe} cmd show";
          "Super_R" = "exec --no-startup-id ${polybarMsgExe} cmd show";
          "--release Super_L" = "exec --no-startup-id ${polybarMsgExe} cmd hide";
          "--release Super_R" = "exec --no-startup-id ${polybarMsgExe} cmd hide";
        };
      };
    };
}
