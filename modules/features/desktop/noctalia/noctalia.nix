{ self, inputs, ... }: {
  perSystem = { pkgs, system, ... }:
    let upkgs = import inputs.nixpkgs-unstable { inherit system; };
    in { packages.noctalia = upkgs.noctalia-shell; };
}
