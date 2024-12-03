{ pkgs, ... }:

{
  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    killall
    brightnessctl
    networkmanagerapplet
    unzip
    poweralertd
    playerctl
    dconf
    notify-desktop

    # Bluetooth devices
    bluez
    libinput
    bluez-tools
    evtest
    blueman

    # Global software    
    gnome.nautilus
    firefox
  ];
}
