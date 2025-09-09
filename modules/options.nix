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
      Active le profil école (limite les languages Helix à C, Nix et Wakatime).
    '';
  };
}
