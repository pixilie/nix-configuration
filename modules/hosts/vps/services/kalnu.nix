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
      sops.secrets.pgadmin_password.owner = "pgadmin";

      services.kalnu = {
        enable = true;
        domain = "kalnu.pixilie.net";
        environmentFile = config.sops.secrets.kalnu_env.path;
      };

      services.pgadmin = {
        enable = true;
        port = 5051;
        initialEmail = "kristen.couty@hydrovinci.fr";
        initialPasswordFile = config.sops.secrets.pgadmin_password.path;
        settings.DEFAULT_SERVER = "127.0.0.1";
      };

      services.caddy.virtualHosts = {
        "kalnu.pixilie.net".extraConfig = ''
          reverse_proxy ${backend}
        '';
        "api.kalnu.pixilie.net".extraConfig = ''
          reverse_proxy ${backend}
        '';
        "pgadmin.kalnu.pixilie.net".extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.services.pgadmin.port}
        '';
      };
    };
}
