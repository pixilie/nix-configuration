{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs.lib) genAttrs;

      forAllSystems = genAttrs [
        "x86_64-linux"
      ];
      forAllPkgs = function: forAllSystems (system: function pkgs.${system});

      pkgs = forAllSystems (
        system:
        (import nixpkgs {
          inherit system;
          overlays = [ ];
        })
      );
    in
    {
      devShells = forAllPkgs (pkgs: {
        default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            binutils
            gcc
            gnumake
            gdb
            strace
          ];
        };
      });
    };
}
