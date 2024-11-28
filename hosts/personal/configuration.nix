{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/utilities.nix
    ../../modules/nixos/security.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/unfree.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 1;
  boot.loader.timeout = 0;

  # Network
  networking.hostName = "kristen-nixos";
  networking.networkmanager.enable = true;

  # System upgrade
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # System packages: drivers, services ...
  #environment.systemPackages = with pkgs; [ wireplumber ];

  # User
  users.users.kristen = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "sway" ];
  };

  # Start sway 
  environment.loginShellInit = ''
    [[ "$(tty)" == /dev/tty1 ]] && sway
  '';

  # System things
  system.stateVersion = "24.05";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
