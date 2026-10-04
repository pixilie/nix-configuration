{ self, ... }:
{

  flake.nixosModules.rpiKalnu = {
    imports = [
      self.nixosModules.rpiKalnuNtfy
      self.nixosModules.rpiKalnuGatus
    ];
  };
}
