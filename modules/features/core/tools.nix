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
        direnv

        # CLI / TUI
        dust
        btop
        fastfetch
        glow
        doggo
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
        claude-code
        claude-monitor
        gemini-cli
      ];
    };
}
