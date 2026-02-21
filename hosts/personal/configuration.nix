{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/special-packages.nix
    ../../modules/nixos/sound.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/security.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/power-management.nix
    ../../modules/nixos/sddm.nix
    ../../modules/nixos/nix_ld.nix
    ../../modules/nixos/virtulisation.nix

    ../../modules/nixos/docker.nix
    ../../modules/nixos/steam.nix

    ../../modules/nixos/sway.nix
  ];

  # Localisation services
  services.automatic-timezoned.enable = true;

  services.geoclue2 = {
    enable = true;
    enableDemoAgent = true;
    geoProviderUrl = "https://beacondb.net/v1/geolocate";
    submissionUrl = "https://beacondb.net/v1/geolocate";
    submitData = true;
  };

  location = {
    provider = "manual";
    # Paris
    # latitude = 48.85;
    # longitude = 2.35;

    # Riga
    latitude = 56.504668;
    longitude = 21.010806;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Garbage collector
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.settings.auto-optimise-store = true;

  # Boot settings
  boot = {
    kernelParams = [ "quiet" ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 10;
      timeout = 0;
    };
  };

  # User related settings
  users.users.kristen = {
    isNormalUser = true;
    extraGroups =
      [ "wheel" "networkmanager" "sway" "input" "gamemode" "libvirtd" ];
  };

  # System related settings
  system = {
    autoUpgrade.enable = true;
    autoUpgrade.allowReboot = true;
    stateVersion = "25.11";
  };

  services.thermald.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.devmon.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
