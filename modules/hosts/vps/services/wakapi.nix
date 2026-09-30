{ upkgsBySystem, ... }:
{

  flake.nixosModules.vpsWakapi =
    { config, ... }:
    {
      sops.secrets.wakapi_env = { };

      services.wakapi = {
        enable = true;
        package = upkgsBySystem.x86_64-linux.wakapi;
        settings = {
          server = {
            listen_ipv4 = "127.0.0.1";
            listen_ipv6 = "-";
            port = 3000;
            public_url = "https://wakapi.pixilie.net";
          };
          db = {
            dialect = "sqlite3";
            name = "wakapi.db";
          };
        };
        environmentFiles = [ config.sops.secrets.wakapi_env.path ];
      };

      services.caddy.virtualHosts."wakapi.pixilie.net".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString config.services.wakapi.settings.server.port}
      '';
    };
}
