{ ... }:
{

  flake.nixosModules.vpsDawarich =
    { config, ... }:
    let
      domain = "maps.pixilie.net";
      cfg = config.services.dawarich;
    in
    {
      sops.secrets.maddy_noreply_password.restartUnits = [
        "dawarich-web.service"
        "dawarich-sidekiq-all.service"
      ];

      services.dawarich = {
        enable = true;
        localDomain = domain;
        webPort = 3010;
        configureNginx = false;
        smtp = {
          host = "127.0.0.1";
          port = 587;
          user = "noreply@pixilie.net";
          fromAddress = "Dawarich <noreply@pixilie.net>";
          passwordFile = config.sops.secrets.maddy_noreply_password.path;
        };
        environment = {
          BINDING = "127.0.0.1";
          WEB_CONCURRENCY = "1";
          SMTP_STARTTLS = "false";
        };
      };

      systemd.services.dawarich-web.after = [ "maddy.service" ];
      systemd.services.dawarich-sidekiq-all.after = [ "maddy.service" ];

      services.caddy.virtualHosts.${domain}.extraConfig = ''
        encode zstd gzip
        root * ${cfg.package}/public
        @static file
        handle @static {
          file_server
        }
        handle {
          reverse_proxy 127.0.0.1:${toString cfg.webPort}
        }
      '';
    };
}
