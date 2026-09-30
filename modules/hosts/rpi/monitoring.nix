{ inputs, ... }:
{

  flake.nixosModules.rpiMonitoring =
    { config, ... }:
    let
      https = group: host: {
        name = host;
        inherit group;
        url = "https://${host}";
        interval = "60s";
        conditions = [
          "[STATUS] < 500"
          "[CERTIFICATE_EXPIRATION] > 168h"
        ];
      };
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        defaultSopsFile = ../../../secrets/rpi.yaml;
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        secrets.beszel_agent_env.restartUnits = [ "beszel-agent.service" ];
      };

      services.beszel.agent = {
        enable = true;
        environment = {
          HUB_URL = "https://beszel.pixilie.net";
          KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICCgncTKfW/Obw8dipvTvisdQ4Qb1HEfWF5vEip2QVdx";
        };
        environmentFile = config.sops.secrets.beszel_agent_env.path;
      };

      services.gatus = {
        enable = true;
        settings = {
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
              name = "vps";
              group = "Server";
              url = "icmp://vps.pixilie.net";
              interval = "60s";
              conditions = [ "[CONNECTED] == true" ];
            }
            (https "Kalnu" "kalnu.pixilie.net")
            (https "Kalnu" "api.kalnu.pixilie.net")
            (https "Kalnu" "pgadmin.kalnu.pixilie.net")
            (https "Garmin dashboard" "garmin.pixilie.net")
            (https "Garmin dashboard" "garmin.mcp.pixilie.net")
            (https "Wakapi" "wakapi.pixilie.net")
            (https "Calendar" "rustical.pixilie.net")
            (https "Calendar" "calino.pixilie.net")
            (https "Monitoring" "beszel.pixilie.net")
          ];
        };
      };

      services.caddy = {
        enable = true;
        virtualHosts."status.pixilie.net".extraConfig = ''
          encode zstd gzip
          reverse_proxy 127.0.0.1:${toString config.services.gatus.settings.web.port}
        '';
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
      networking.firewall.allowedUDPPorts = [ 443 ];
    };
}
