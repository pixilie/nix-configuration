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
    ../../modules/nixos/system-packages.nix
    ../../modules/nixos/power-management.nix
    ../../modules/nixos/sway.nix
    # ../../modules/nixos/sddm.nix
  ];

  time.timeZone = "Europe/Riga";

  nix.gc = {
    automatic = true;
    dates = "monthly";
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      # Select last derivation instantly
      systemd-boot.configurationLimit = 1;
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
