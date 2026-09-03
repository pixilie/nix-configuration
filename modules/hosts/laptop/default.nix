{
  self,
  inputs,
  upkgsBySystem,
  ...
}:
let
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  upkgs = upkgsBySystem.${system};
in
{
  flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
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
