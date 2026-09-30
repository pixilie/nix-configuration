{ self, inputs, ... }:
{
  flake.nixosConfigurations.vps = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      self.nixosModules.vpsConfiguration
    ];
  };
}
