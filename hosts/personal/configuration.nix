{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/special-packages.nix
    ../../modules/nixos/utilities.nix
    ../../modules/nixos/security.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/steam.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/system-packages.nix
    ../../modules/nixos/power-management.nix
    # ../../modules/nixos/sddm.nix
  ];

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
