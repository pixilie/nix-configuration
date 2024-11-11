{config, pkgs, ...}:

{
  programs.i3status-rust = {
    enable = true;
    default = {
      theme = "ctp-mocha";
      icons = "awesome6";

      blocks = [
        {
          block = "time";
          interval = 60;
          format = " $timestamp.datetime(f:'%a %d/%m %R') ";
        }
        {
           block = "disk_space";
           path = "/";
           info_type = "available";
           interval = 60;
           warning = 20.0;
           alert = 10.0;
        }
        { block = "battery"; }
        { block = "cpu"; }
        {
          block = "memory";
          format = " $icon $mem_used_percents.eng(w:2) ";
        }
        { block = "net"; }
        { block = "sound"; }
        { block = "music"; }
      ];
    };
  };

  wayland.windowManager.sway.config.bars = {
    command = "i3status-rust";
    hiddenState = "hide";
    mode = "hide";
    fonts.size = 11.0;

    colors = {
    };  
  };
}
