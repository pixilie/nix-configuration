{ self, ... }:
{

  flake.homeModules.vpsHome =
    { ... }:
    {
      imports = [
        self.homeModules.shPersonal

        self.homeModules.options
      ];

      config = {
        home.username = "kristen";
        home.homeDirectory = "/home/kristen";
        home.stateVersion = "26.05";
      };
    };
}
