{ ... }:
{

  flake.nixosModules.rpiNtfy =
    { config, ... }:
    let
      listen = "127.0.0.1:2586";
    in
    {
      sops.secrets.ntfy_env.restartUnits = [ "ntfy-sh.service" ];

      services.ntfy-sh = {
        enable = true;
        environmentFile = config.sops.secrets.ntfy_env.path;
        settings = {
          base-url = "https://ntfy.pixilie.net";
          listen-http = listen;
          behind-proxy = true;
          auth-default-access = "deny-all";
          enable-login = true;
          upstream-base-url = "https://ntfy.sh";
        };
      };

      services.caddy.virtualHosts."ntfy.pixilie.net".extraConfig = ''
        reverse_proxy ${listen}
      '';
    };
}
