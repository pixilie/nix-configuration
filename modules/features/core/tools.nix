{ self, inputs, ... }:
{

  flake.homeModules.tools =
    { pkgs, upkgs, ... }:
    {
      home.packages = with pkgs; [
        wl-clipboard
        dconf
        openssl
        pkg-config
        xdg-utils
        direnv

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
        gnumake
        killall
        tokei
        television
        miniserve
        unzip
        upkgs.claude-code
        wireshark-cli

        # concord-tui
        # discordo
      ];
    };
}
