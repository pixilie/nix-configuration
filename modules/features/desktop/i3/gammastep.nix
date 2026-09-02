{ self, inputs, ... }:
{

  flake.homeModules.gammastepI3 =
    { pkgs, ... }:
    {
      services.gammastep = {
        enable = true;
        provider = "geoclue2";

        temperature = {
          day = 5700;
          night = 3200;
        };

        settings = {
          general = {
            fade = "1";
            adjustment-method = "randr";
          };
        };
      };
    };
}
