{ pkgs, ... }:

{
  programs.i3status-rust = {
    enable = true;
    bars.default = {
      icons = "awesome6";
      theme = "modern";

      settings = {
        theme = {
          theme = "modern";
          overrides = {
            separator = "<span size='14000'></span>";
            idle_bg = "#17191e";
          };
        };
      };

      blocks = [
        { block = "sound"; }
        {
          block = "music";
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
          block = "time";
          format = " $icon $timestamp.datetime(f:'%a %d/%m %R')";
        }
      ];
    };
  };

  xsession.windowManager.i3.config.bars = [{
    statusCommand =
      "${pkgs.i3status-rust}/bin/i3status-rs /home/kristen.couty/.config/i3status-rust/config-default.toml";
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
}
