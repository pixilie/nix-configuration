{ pkgs, ... }:

{
  gtk = {
    enable = true;

    theme.package = pkgs.solarc-gtk-theme;
    theme.name = "SolArc-Dark";

    iconTheme.package = pkgs.paper-gtk-theme;
    iconTheme.name = "Paper";

    cursorTheme.package = pkgs.paper-gtk-theme;
    cursorTheme.name = "Paper";

  };

  #wayland.windowManager.sway.wrapperFeatures.gtk = true; IDK NOT WORKING
}
