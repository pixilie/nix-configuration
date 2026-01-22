{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/special-packages.nix
    ../../modules/nixos/sound.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/security.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/steam.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/power-management.nix
    ../../modules/nixos/sway.nix
    ../../modules/nixos/sddm.nix
    ../../modules/nixos/nix_ld.nix
  ];

  services.automatic-timezoned.enable = true;

  services.geoclue2 = {
    enable = true;
    enableDemoAgent = true;
    geoProviderUrl = "";
  };

  location = {
    provider = "manual";
    # Paris
    # latitude = 48.85;
    # longitude = 2.35;

    # Riga
    latitude = 56.95;
    longitude = 24.11;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.settings.auto-optimise-store = true;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 10;
      timeout = 0;
    };
  };

  system = {
    autoUpgrade.enable = true;
    autoUpgrade.allowReboot = true;
    stateVersion = "25.11";
  };

  users.users.kristen = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "sway" "input" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
