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

  # Packages
  environment.systemPackages = with pkgs; [
    # TODO: split system pkg and tool in two specific files
    pipewire
    grim
    slurp
    wl-clipboard
    killall
    brightnessctl
    wireplumber
    networkmanagerapplet
    unzip
    poweralertd
    upower
    xdg-desktop-portal-gtk
    pkg-config
  ];

  # User
  users.users.kristen = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "sway" ];
  };

  # Start sway 
  environment.loginShellInit = ''
    [[ "$(tty)" == /dev/tty1 ]] && sway
  '';

  #System things
  system.stateVersion = "24.05";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
