{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    where-is-my-sddm-theme
    qt6Packages.qt6ct
  ];

  services.displayManager.defaultSession = "sway";

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "where_is_my_sddm_theme";

    extraPackages = [
      pkgs.qt6Packages.qt5compat
      pkgs.qt6Packages.qtsvg
      pkgs.qt6Packages.qtdeclarative
    ];

    settings = {
      General = {
        SessionCommand = "${pkgs.sway}/bin/sway";
        DisplayServer = "wayland";
      };
    };
  };

  environment.variables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
  };
}
