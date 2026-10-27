{ ... }:
{

  flake.nixosModules.rpiKalnuGatus =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (import ./_settings.nix) sopsFile ntfyListen gatusPort;

      alerts = [ { type = "ntfy"; } ];

      https = host: {
        name = host;
        group = "Kalnu";
        url = "https://${host}";
        interval = "60s";
        conditions = [
          "[STATUS] < 500"
          "[CERTIFICATE_EXPIRATION] > 168h"
          "[RESPONSE_TIME] < 500"
        ];
        inherit alerts;
      };

      # One Kalnu component, from /api/health/<name> (services/health.py): 503 when down, `status` ok |
      # degraded | down | disabled in the body. `[BODY].status == ok` also alerts on « degraded ».
      component = name: label: {
        name = label;
        group = "Kalnu services";
        url = "https://api.kalnu.fr/api/health/${name}";
        interval = "60s";
        conditions = [
          "[STATUS] == 200"
          "[BODY].status == ok"
          "[RESPONSE_TIME] < 3000"
        ];
        inherit alerts;
      };

      # One data source (Garmin, COROS, Suunto, Strava) or calendar provider. A source switched off on the
      # instance is red too, with its own value: the failed condition reads « (disabled) » instead of
      # « (degraded) » for a source that fails.
      source = name: label: {
        name = label;
        group = "Kalnu sources";
        url = "https://api.kalnu.fr/api/health/${name}";
        interval = "60s";
        conditions = [
          "[STATUS] == 200"
          "[BODY].status == ok"
          "[RESPONSE_TIME] < 3000"
        ];
        inherit alerts;
      };

      # MCP hosts seen from outside: their public OAuth metadata, served by the MCP app itself.
      mcpHost = host: {
        name = "${host} (OAuth metadata)";
        group = "Kalnu";
        url = "https://${host}/.well-known/oauth-protected-resource";
        interval = "60s";
        conditions = [
          "[STATUS] == 200"
          "[BODY].resource == https://${host}/"
          "[RESPONSE_TIME] < 1000"
        ];
        inherit alerts;
      };

      gatusConfig = (pkgs.formats.yaml { }).generate "gatus-kalnu.yaml" {
        alerting.ntfy = {
          url = "http://${ntfyListen}";
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
          port = gatusPort;
        };
        storage = {
          type = "sqlite";
          path = "/var/lib/gatus-kalnu/data.db";
        };
        ui = {
          title = "Kalnu status";
          header = "Kalnu";
        };
        endpoints = [
          (https "kalnu.fr")
          (mcpHost "mcp.kalnu.fr")
          (mcpHost "mcp.admin.kalnu.fr")
          {
            name = "Kalnu (all components)";
            group = "Kalnu";
            url = "https://api.kalnu.fr/api/health/all";
            interval = "60s";
            conditions = [
              "[STATUS] == 200"
              "[BODY].status == ok"
              "[RESPONSE_TIME] < 3000"
            ];
            # Shown on the page but silent: each component and source has its own alert.
          }
          (component "db" "Database")
          (component "mcp" "MCP server")
          (component "admin_mcp" "Admin MCP server")
          (component "brouter" "BRouter (GPX editor routing)")
          (component "workers" "Background workers")
          (component "sync" "Data sync")
          (source "garmin" "Garmin")
          (source "coros" "COROS")
          (source "suunto" "Suunto")
          (source "strava" "Strava")
          (source "google_calendar" "Google Calendar")
          (source "microsoft_calendar" "Microsoft calendar (Outlook)")
          (source "caldav" "CalDAV calendars")
          (component "storage" "Storage")
          {
            name = "ntfy.kalnu.fr";
            group = "Kalnu";
            url = "https://ntfy.kalnu.fr/v1/health";
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
    in
    {
      sops.secrets.gatus_kalnu_env = {
        inherit sopsFile;
        restartUnits = [ "gatus-kalnu.service" ];
      };

      systemd.services.gatus-kalnu = {
        description = "Kalnu status page";
        after = [
          "network-online.target"
          "ntfy-kalnu.service"
        ];
        requires = [ "network-online.target" ];
        wants = [ "ntfy-kalnu.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          DynamicUser = true;
          User = "gatus-kalnu";
          Group = "gatus-kalnu";
          Type = "simple";
          Restart = "on-failure";
          ExecStart = lib.getExe pkgs.gatus;
          StateDirectory = "gatus-kalnu";
          SyslogIdentifier = "gatus-kalnu";
          EnvironmentFile = config.sops.secrets.gatus_kalnu_env.path;
          NoNewPrivileges = true;
        };

        environment.GATUS_CONFIG_PATH = gatusConfig;
      };

      services.caddy.virtualHosts."status.kalnu.fr".extraConfig = ''
        encode zstd gzip
        reverse_proxy 127.0.0.1:${toString gatusPort}
      '';
    };
}
