{ self, inputs, ... }:
{

  flake.nixosModules.nix_ld =
    { pkgs, ... }:
    {
      programs.nix-ld.enable = true;

      programs.nix-ld.libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        openssl
        curl
        glib
        util-linux

        gtk3
        cairo
        pango
        gdk-pixbuf
        freetype
        fontconfig

        libx11
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxrandr
        libxcb
        libxrender
        libxi
        libxtst

        libGL
        vulkan-loader
        mesa

        alsa-lib
        pulseaudio

        nss
        nspr
        cups
        dbus
        expat
        libdrm
        at-spi2-atk
        at-spi2-core
      ];
    };
}
