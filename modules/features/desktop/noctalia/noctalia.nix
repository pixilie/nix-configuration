{ self, inputs, ... }: {
  perSystem = { upkgs, ... }:
    {

      packages.noctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        pkgs = upkgs;

        settings = builtins.fromJSON (builtins.readFile ./noctalia.json);
      };
    };
}
