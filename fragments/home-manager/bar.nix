{config, pkgs, lib, ...}:

{
  programs.i3status-rust = {
    enable = true;
    bars.default = {
      icons = "awesome6";     
      theme = "ctp-mocha";

      settings = {
        theme =  {
          theme = "modern";
          overrides = {
            separator = "<span size='15000'></span>";
          };
        };
      };
     
      blocks = [
        { block = "sound"; }
        { 
           block = "net";
           format = " $icon  $ssid ($signal_strength) ";
           interval = 60;
        }
        {
          block = "memory";
          icons_format = "";
          format = " $icon$mem_used_percents.eng(w:2) ";
          interval = 10;
        }
        {
           block = "cpu";
           icons_format = "";
           format = " $icon$utilization ";
           interval = 10;
        }
        {
            block = "battery";
            interval = 30;
        }
        {
           block = "disk_space";
           path = "/";
           info_type = "available";
           interval = 60;
        }
        {
          block = "time";
          interval = 60;
          format = " $icon $timestamp.datetime(f:'%a %d/%m %R') ";
        }
      ];
    };
  };

  wayland.windowManager.sway.config.bars =[{
    statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs /home/kristen/.config/i3status-rust/config-default.toml";
    mode = "hide";
    fonts.size = 11.0;

    colors = {
        background = "#282c34";
        focusedBackground = "#282c34";
        separator = "#cccccc";
        focusedSeparator = "#cccccc";
        statusline = "#cccccc";
        focusedStatusline = "#cccccc";

        focusedWorkspace = rec {
          text = "#ffffff";
          background = "#42b3c2";
          border = background;
        };

        inactiveWorkspace = rec {
          text = "#abb2bf";
          background = "#3f4451";
          border = background;
        };

        activeWorkspace = rec {
          text = "#e05561";
          background = "#42b3c2";
          border = background;
        };

        urgentWorkspace = rec {
          text = "#ffffff";
          background = "#bf4034";
          border = background;
        };
      };
  }];
}
