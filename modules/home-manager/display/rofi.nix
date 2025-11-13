{ lib, ... }: {
  xsession.windowManager.i3.config.keybindings = lib.mkOptionDefault {
    "Mod4+d" = "exec rofi -show drun";
    "Mod4+Shift+d" = "exec rofi -show run";
  };

  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
    "Mod4+d" = "exec rofi -show drun";
    "Mod4+Shift+d" = "exec rofi -show run";
  };

  programs.rofi = {
    enable = true;
    theme = ../../../assets/themes/rofi.rasi;
  };
}

