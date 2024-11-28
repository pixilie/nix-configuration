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

    # Global software    
    gnome.nautilus
    firefox
  ];
}
