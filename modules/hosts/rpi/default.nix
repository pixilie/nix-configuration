{ self, inputs, ... }:
{
  flake.nixosConfigurations.rpi = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      self.nixosModules.rpiConfiguration
    ];
  };
}
