{ self, inputs, ... }:
let
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  upkgs = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  flake.nixosConfigurations.personal = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs upkgs; };
    modules = [
      self.nixosModules.laptopConfiguration
    ];
  };

  flake.homeConfigurations.laptop = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = { inherit inputs upkgs; };
    modules = [
      self.homeModules.laptopHome
    ];
  };
}
