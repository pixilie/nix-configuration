{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11"; };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs.lib) genAttrs;

      forAllSystems =
        genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllPkgs = function: forAllSystems (system: function pkgs.${system});

      pkgs = forAllSystems (system:
        (import nixpkgs {
          inherit system;
          overlays = [ ];
        }));
    in {
      devShells = forAllPkgs (pkgs:
        with pkgs.lib; {
          default = pkgs.mkShell rec {
            nativeBuildInputs = with pkgs; [
              python312Packages.ipython
              ruff
              python312Packages.jedi-language-server
              python312Packages.python-lsp-server
            ];
            buildInputs = with pkgs; [ ];

            LD_LIBRARY_PATH = makeLibraryPath buildInputs;
          };
        });
    };
}
