{ self, inputs, ... }:
{

  flake.nixosModules.docker =
    { ... }:
    {
      virtualisation.docker = {
        enable = true;

        rootless = {
          enable = true;
          setSocketVariable = true;
        };

        autoPrune = {
          enable = true;
          dates = "weekly";
        };
      };
    };
}
