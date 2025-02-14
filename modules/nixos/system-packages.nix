{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bluez-tools
    evtest
    bluez
    alsa-utils
  ];
}
