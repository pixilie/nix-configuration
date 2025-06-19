{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libsForQt5.qt5.qtgraphicaleffects
    qt5.qtwayland
    qt6.qtwayland
    libsForQt5.qt5ct
    qt6ct
    (callPackage ../../pkgs/sddm-theme.nix { })
  ];

  services.displayManager.defaultSession = "sway";

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "where-is-my-sddm-theme";

    settings = {
      General = {
        SessionCommand = "${pkgs.sway}/bin/sway";
        DisplayServer = "wayland";
      };
    };
  };

  environment.etc."xdg/wayland-sessions/sway.desktop".text = ''
    [Desktop Entry]
    Name=Sway
    Comment=An i3-compatible Wayland compositor
    Exec=${pkgs.sway}/bin/sway
    Type=Application
    DesktopNames=Sway
  '';

  environment.variables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    WLR_NO_HARDWARE_CURSORS =
      "1"; # Utile si tu as des problèmes de curseur invisible
  };
}
