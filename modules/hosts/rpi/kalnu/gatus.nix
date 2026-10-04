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
          (https "api.kalnu.fr")
          (https "mcp.kalnu.fr")
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
