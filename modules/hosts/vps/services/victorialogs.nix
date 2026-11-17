{ ... }:
{

  flake.nixosModules.vpsVictorialogs =
    { config, ... }:
    let
      domain = "logs.pixilie.net";
      listen = "127.0.0.1:9428";
    in
    {
      sops.secrets.victorialogs_password_hash.restartUnits = [ "caddy.service" ];

      sops.templates."caddy.env" = {
        restartUnits = [ "caddy.service" ];
        content = ''
          LOGS_AUTH_HASH='${config.sops.placeholder.victorialogs_password_hash}'
        '';
      };

      services.victorialogs = {
        enable = true;
        listenAddress = listen;
        extraOptions = [
          "-retentionPeriod=30d"
          "-retention.maxDiskSpaceUsageBytes=5GiB"
        ];
      };

      services.journald.upload = {
        enable = true;
        settings.Upload.URL = "http://${listen}/insert/journald";
      };

      services.caddy.environmentFile = config.sops.templates."caddy.env".path;

      services.caddy.virtualHosts.${domain}.extraConfig = ''
        encode zstd gzip
        basic_auth {
          kristen {$LOGS_AUTH_HASH}
        }
        redir / /select/vmui/ 302
        reverse_proxy ${listen}
      '';
    };
}
