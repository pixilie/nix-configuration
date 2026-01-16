{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wl-clipboard
    networkmanagerapplet
    unzip
    poweralertd
    dconf
    openssl
    wdisplays
    pkg-config
    imv
    xdg-utils
    # wireguard-tools
    pavucontrol
    # rclone

    # CLI / TUI
    dust
    btop
    fastfetch
    glow
    dogdns
    speedtest-go
    ripgrep
    jless
    jq
    nix-inspect
    nixos-anywhere
    nix-tree
    killall
    tokei
    television
    miniserve

    # Dev related
    gccgo14
    rustup
    python3
    direnv
    gnumake
    # dotnetCorePackages.sdk_7_0
    # jdk17
    # ldtk
  ];
}
