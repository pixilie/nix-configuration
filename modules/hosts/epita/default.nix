{ self, inputs, ... }:
let
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  upkgs = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  flake.homeConfigurations.epita = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = { inherit inputs upkgs; };
    modules = [
      self.homeModules.epitaHome
    ];
  };
}
