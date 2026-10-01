{ inputs, ... }:
{

  flake.nixosModules.vpsKalnu =
    { config, ... }:
    let
      backend = "127.0.0.1:${toString config.services.kalnu.port}";
    in
    {
      imports = [ inputs.kalnu.nixosModules.default ];

      sops.secrets.kalnu_env = {
        owner = config.services.kalnu.user;
        restartUnits = [ "kalnu.service" ];
      };

      services.kalnu = {
        enable = true;
        domain = "kalnu.pixilie.net";
        environmentFile = config.sops.secrets.kalnu_env.path;
      };

      services.caddy.virtualHosts = {
        "kalnu.pixilie.net".extraConfig = ''
          reverse_proxy ${backend}
        '';
        "api.kalnu.pixilie.net".extraConfig = ''
          reverse_proxy ${backend}
        '';
      };
    };
}
