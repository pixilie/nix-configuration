{ upkgsBySystem, ... }:
{

  flake.nixosModules.vpsBeszel =
    { config, ... }:
    let
      beszel = upkgsBySystem.x86_64-linux.beszel;
    in
    {
      services.beszel.hub = {
        enable = true;
        package = beszel;
        host = "127.0.0.1";
        port = 8090;
        environment.APP_URL = "https://beszel.pixilie.net";
      };

      services.beszel.agent = {
        enable = true;
        package = beszel;
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
