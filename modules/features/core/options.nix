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

      options.isSchoolProfile = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether this profile is dedicated for school or not
        '';
      };

      options.isLightProfile = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether this profile is stripped down to the bare minimum, leaving
          terminal styling and extra CLI tooling out
        '';
      };
    };
in
{

  flake.nixosModules.options = sharedOptions;
  flake.homeModules.options = sharedOptions;
}
