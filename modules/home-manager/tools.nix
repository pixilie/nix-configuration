{ pkgs, inputs, ... }:

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
    pavucontrol

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
    nil
    nixd
    wakatime-cli
    inputs.wakatime-ls.packages."x86_64-linux".wakatime-ls
    dbeaver-bin
  ];
}
