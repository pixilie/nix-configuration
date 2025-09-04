{ pkgs, lib, config, ... }:

{
  config = {
    programs.i3status-rust = {
      enable = true;
      bars.default = {
        icons = "awesome6";
        theme = "modern";

        settings = {
          theme = {
            theme = "modern";
            overrides = {
              separator = "<span size='18000'></span>";
              idle_bg = "#17191e";
            };
          };
        };

        blocks = [
          { block = "sound"; }
          {
            block = "net";
            format = " $icon  $ssid ($signal_strength) ";
          }
          {
            block = "memory";
            icons_format = "";
            format = " $icon $mem_used_percents.eng(w:2) ";
          }
          {
            block = "cpu";
            icons_format = "";
            format = " $icon $utilization ";
          }
          {
            block = "battery";
            driver = "upower";
            interval = 30;
            warning = 20;
            critical = 10;
            format = " $icon $percentage ";
            empty_format = " $icon $percentage ";
            full_format = " $icon $percentage ";
          }
          {
            block = "disk_space";
            path = "/";
            info_type = "available";
          }
          {
            block = "time";
            format = " $icon $timestamp.datetime(f:'%a %d/%m %R')";
          }
          {
            block = "custom";
            json = true;
            command = ''
              if ${lib.getExe' pkgs.ripgrep "rg"} -q dnd <<< "$(${
                lib.getExe' pkgs.mako "makoctl"
              } mode)"; then
                echo '{"text": " "}'
              else
                echo '{"text": " "}'
              fi
            '';
            click = [{
              button = "left";
              cmd = ''
                ${lib.getExe' pkgs.mako "makoctl"} mode -t dnd
              '';
              update = true;
            }];
            interval = 5;
          }
        ];
      };
    };

    wayland.windowManager.sway.config.bars = lib.mkIf (!config.useFulli3) [{
      statusCommand =
        "${pkgs.i3status-rust}/bin/i3status-rs /home/kristen/.config/i3status-rust/config-default.toml";
      mode = "hide";
      fonts.size = 11.0;

      colors = {
        background = "#17191e";

        focusedWorkspace = rec {
          text = "#ffffff";
          background = "#61AFEF";
          border = background;
        };

        inactiveWorkspace = rec {
          text = "#abb2bf";
          background = "#282c34";
          border = background;
        };

        urgentWorkspace = rec {
          text = "#ffffff";
          background = "#bf4034";
          border = background;
        };
      };
    }];

    xsession.windowManager.i3.config.bars = lib.mkIf config.useFulli3 [{
      statusCommand =
        "${pkgs.i3status-rust}/bin/i3status-rs /home/kristen/.config/i3status-rust/config-default.toml";
      mode = "hide";
      fonts = { size = 11.0; };

      colors = {
        background = "#17191e";

        focusedWorkspace = rec {
          text = "#ffffff";
          background = "#61AFEF";
          border = background;
        };

        inactiveWorkspace = rec {
          text = "#abb2bf";
          background = "#282c34";
          border = background;
        };

        urgentWorkspace = rec {
          text = "#ffffff";
          background = "#bf4034";
          border = background;
        };
      };
    }];
  };
}
