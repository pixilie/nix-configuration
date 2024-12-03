{ pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Garbage collector
  nix.gc = {
    automatic = true;
    dates = "monthly";
  };

  # Enable sound.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Sway
  security.polkit.enable = true;

  # Power
  services.upower = {
    enable = true;
    percentageLow = 10;
    percentageCritical = 5;
    timeCritical = 120;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

}
