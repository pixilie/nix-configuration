{ inputs, lib, ... }:
let
  upkgsBySystem = lib.genAttrs [ "x86_64-linux" ] (
    system:
    import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    }
  );
in
{
  _module.args.upkgsBySystem = upkgsBySystem;

  perSystem =
    { system, ... }:
    {
      _module.args.upkgs = upkgsBySystem.${system};
    };
}
