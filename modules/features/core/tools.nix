{ self, inputs, ... }:
{

  flake.homeModules.tools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        wl-clipboard
        dconf
        openssl
        pkg-config
        xdg-utils
        direnv
        man-pages

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
        inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
        ipcalc
        wl-mirror
      ];
    };
}
