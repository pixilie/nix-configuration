{ self, inputs, ... }: {
  perSystem = { pkgs, system, ... }:
    let upkgs = import inputs.nixpkgs-unstable { inherit system; };
    in {

      packages.noctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        pkgs = upkgs;

        settings = builtins.fromJSON (builtins.readFile ./noctalia.json);
      };
    };
}
