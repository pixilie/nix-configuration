{ lib, config, ... }:
let
  darkTheme = ../../../assets/themes/rofi_dark.rasi;
  lightTheme = ../../../assets/themes/rofi_light.rasi;
in {
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
    theme = "current";
  };

  xdg.dataFile."rofi/themes/dark.rasi".source = darkTheme;
  xdg.dataFile."rofi/themes/light.rasi".source = lightTheme;

  home.activation.ensureRofiTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "${config.xdg.dataHome}/rofi/themes/current.rasi" ]; then
      ln -s "${config.xdg.dataHome}/rofi/themes/dark.rasi" "${config.xdg.dataHome}/rofi/themes/current.rasi"
    fi
  '';
}
