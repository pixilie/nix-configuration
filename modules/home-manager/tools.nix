{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wl-clipboard
    killall
    networkmanagerapplet
    unzip
    poweralertd
    dconf
    openssl
    wdisplays
    fastfetch
    pkg-config
    imv
    xdg-utils
    wireguard-tools

    # Dev related
    gccgo14
    rustup
    python3
    dotnetCorePackages.sdk_7_0
    direnv
    gnumake
    jdk17
  ];
}
