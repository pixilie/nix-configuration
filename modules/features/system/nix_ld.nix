{ self, inputs, ... }:
{

  flake.nixosModules.nix_ld =
    { pkgs, ... }:
    {
      programs.nix-ld.enable = true;

      programs.nix-ld.libraries = with pkgs; [
        # General
        stdenv.cc.cc.lib
        zlib
        openssl
        curl
        glib
        util-linux

        # UI
        gtk3
        cairo
        pango
        gdk-pixbuf
        freetype
        fontconfig

        # X11 & Wayland
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

        # Rendu 3D
        libGL
        vulkan-loader
        mesa

        # Son
        alsa-lib
        pulseaudio

        # Web / Electron
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
