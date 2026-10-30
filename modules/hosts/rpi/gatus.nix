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

      health = group: host: path: checks: {
        name = host;
        inherit group;
        url = "https://${host}${path}";
        interval = "60s";
        conditions = [
          "[STATUS] == 200"
        ]
        ++ checks
        ++ [
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
            (health "Wakapi" "wakapi.pixilie.net" "/api/health" [ "[BODY] == pat(*app=1*db=1*)" ])

            (health "Vaultwarden" "vault.pixilie.net" "/alive" [ ])

            (health "Cloud" "cloud.pixilie.net" "/status.php" [
              "[BODY].installed == true"
              "[BODY].maintenance == false"
            ])
            (health "Cloud" "photos.pixilie.net" "/api/server/ping" [ "[BODY].res == pong" ])

            (health "Calendar" "rustical.pixilie.net" "/ping" [ "[BODY] == Pong!" ])
            (health "Calendar" "calsync.pixilie.net" "/health" [ "[BODY] == ok" ])

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

            (health "Miniflux" "rss.pixilie.net" "/healthcheck" [ "[BODY] == OK" ])

            (health "Jellyfin" "media.pixilie.net" "/health" [ "[BODY] == Healthy" ])

            (https "Games" "games.pixilie.net")

            (health "Monitoring" "beszel.pixilie.net" "/api/health" [ ])
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
