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
    pkg-config
    imv
    xdg-utils
    wireguard-tools
    pavucontrol
    rclone
    nix-inspect
    nixos-anywhere
    nix-tree

    # Cli
    dust
    btop
    onefetch
    fastfetch
    glow
    dogdns
    speedtest-go
    gh-dash
    ripgrep
    jless
    jq

    # Dev related
    gccgo14
    rustup
    python3
    # dotnetCorePackages.sdk_7_0
    direnv
    gnumake
    # jdk17
    # ldtk
  ];
}
