{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 1;
  boot.loader.timeout = 0;
  
  # Network
  networking.hostName = "kristen-nixos";
  networking.networkmanager.enable = true;

  # Garbage collector
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

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
  hardware.opengl = {
    enable = true;
    driSupport = true;
 };
  # Packages
  environment.systemPackages = with pkgs; [
    pipewire
  ];
    
  # User
  users.users.kristen = {
     isNormalUser = true;
     extraGroups = [ "wheel" "networkmanager" "sway" ];
   };
  #System things
  system.stateVersion = "24.05";
  nix.settings.experimental-features = ["nix-command" "flakes"];
}
