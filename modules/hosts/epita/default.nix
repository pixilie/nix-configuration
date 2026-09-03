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
  flake.homeConfigurations.epita = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = { inherit inputs upkgs; };
    modules = [
      self.homeModules.epitaHome
    ];
  };
}
