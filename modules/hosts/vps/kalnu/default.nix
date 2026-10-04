{ self, ... }:
{

  flake.nixosModules.vpsKalnu = {
    imports = [
      self.nixosModules.vpsKalnuApp
      self.nixosModules.vpsKalnuMail
    ];
  };
}
