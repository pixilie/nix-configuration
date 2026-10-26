{ ... }:
{

  flake.nixosModules.vpsBeszel =
    { config, ... }:
    {
      services.beszel.hub = {
        enable = true;
        host = "127.0.0.1";
        port = 8090;
        environment.APP_URL = "https://beszel.pixilie.net";
      };

      services.beszel.agent = {
        enable = true;
        environment = {
          LISTEN = "127.0.0.1:45876";
          KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICCgncTKfW/Obw8dipvTvisdQ4Qb1HEfWF5vEip2QVdx";
        };
      };

      services.caddy.virtualHosts."beszel.pixilie.net".extraConfig = ''
        encode zstd gzip
        reverse_proxy 127.0.0.1:${toString config.services.beszel.hub.port}
      '';
    };
}
