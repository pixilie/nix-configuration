{ ... }:

let modifier = "Mod4";
in {
  xsession.windowManager.i3 = {
    enable = true;
    config.keybindings = {
      "${modifier}+Shift+Return" = "exec firefox";
      "${modifier}+Escape" = "exec i3lock";
    };
  };
}
