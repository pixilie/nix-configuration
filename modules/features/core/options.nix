{ self, inputs, ... }:
let
  sharedOptions =
    { lib, ... }:
    {
      options.useHelixCache = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to use nixpkgs cache or not";
      };

      options.useZedCache = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to use nixpkgs-unstable zed instead of the upstream flake";
      };
    };
in
{

  flake.nixosModules.options = sharedOptions;
  flake.homeModules.options = sharedOptions;
}
