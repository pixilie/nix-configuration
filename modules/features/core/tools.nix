{ self, inputs, ... }:
{

  flake.homeModules.tools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # System utilities
        wl-clipboard
        poweralertd
        dconf
        openssl
        pkg-config
        xdg-utils

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
        unzip

        # Dev related
        gccgo14
        rustup
        python3
        direnv
        gnumake
        nil
        nixd
      ];
    };
}
