{ ... }:
{
  flake.nixosModules.rpiGatus =
    { config, ... }:
    let
      alerts = [ { type = "ntfy"; } ];

      https = group: host: {
        name = host;
        inherit group;
        url = "https://${host}";
        interval = "60s";
        conditions = [
          "[STATUS] < 500"
          "[CERTIFICATE_EXPIRATION] > 168h"
          "[RESPONSE_TIME] < 500"
        ];
        inherit alerts;
      };
    in
    {
      sops.secrets.gatus_env.restartUnits = [ "gatus.service" ];

      services.gatus = {
        enable = true;
        environmentFile = config.sops.secrets.gatus_env.path;
        settings = {
          external-endpoints = [
            {
              name = "Maddy";
              group = "Mail";
              token = "\${GATUS_MADDY_TOKEN}";
              heartbeat.interval = "5m";
              inherit alerts;
            }
          ];
          alerting.ntfy = {
            url = "http://${config.services.ntfy-sh.settings.listen-http}";
            topic = "alerts";
            token = "\${GATUS_NTFY_TOKEN}";
            priority = 4;
            default-alert = {
              failure-threshold = 3;
              success-threshold = 2;
              send-on-resolved = true;
            };
          };
          web = {
            address = "127.0.0.1";
            port = 8080;
          };
          storage = {
            type = "sqlite";
            path = "/var/lib/gatus/data.db";
          };
          ui = {
            title = "Status";
            header = "Status";
          };
          endpoints = [
            {
              name = "VPS";
              group = "Server";
              url = "icmp://vps.pixilie.net";
              interval = "60s";
              conditions = [
                "[CONNECTED] == true"
                "[RESPONSE_TIME] < 500"
              ];
              inherit alerts;
            }
            (https "Garmin dashboard" "garmin.pixilie.net")
            (https "Garmin dashboard" "garmin.mcp.pixilie.net")

            (https "Wakapi" "wakapi.pixilie.net")

            (https "Vaultwarden" "vault.pixilie.net")

            (https "Cloud" "cloud.pixilie.net")
            (https "Cloud" "photos.pixilie.net")

            (https "Calendar" "rustical.pixilie.net")
            (https "Calendar" "calino.pixilie.net")
            (https "Calendar" "calsync.pixilie.net")

            (https "Monitoring" "beszel.pixilie.net")
            (https "Monitoring" "pgadmin.pixilie.net")
            {
              name = "ntfy.pixilie.net";
              group = "Monitoring";
              url = "https://ntfy.pixilie.net/v1/health";
              interval = "60s";
              conditions = [
                "[STATUS] == 200"
                "[BODY].healthy == true"
                "[CERTIFICATE_EXPIRATION] > 168h"
                "[RESPONSE_TIME] < 500"
              ];
            }
          ];
        };
      };

      services.caddy.virtualHosts."status.pixilie.net".extraConfig = ''
        encode zstd gzip
        reverse_proxy 127.0.0.1:${toString config.services.gatus.settings.web.port}
      '';
    };
}
