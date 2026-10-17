{ inputs, upkgsBySystem, ... }:
{

  flake.nixosModules.vpsOpencloud =
    { config, ... }:
    let
      domain = "cloud.pixilie.net";
      cfg = config.services.opencloud;
      storageRoot = cfg.settings.storage-users.drivers.decomposed.root;
    in
    {
      disabledModules = [ "services/web-apps/opencloud.nix" ];
      imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/opencloud.nix" ];

      sops.secrets.opencloud_admin_password = { };

      sops.templates."opencloud.env" = {
        restartUnits = [ "opencloud.service" ];
        content = ''
          IDM_ADMIN_PASSWORD=${config.sops.placeholder.opencloud_admin_password}
          NOTIFICATIONS_SMTP_PASSWORD=${config.sops.placeholder.maddy_noreply_password}
        '';
      };

      services.opencloud = {
        enable = true;
        package = upkgsBySystem.x86_64-linux.opencloud-production;
        url = "https://${domain}";
        environmentFile = config.sops.templates."opencloud.env".path;
        environment = {
          OC_INSECURE = "true";
          OC_ADD_RUN_SERVICES = "notifications";
        };
        settings = {
          proxy = {
            http.tls = false;
            allow_app_auth = true;
          };
          storage-users = {
            driver = "decomposed";
            drivers.decomposed.root = "/mnt/storagebox/opencloud";
            events.num_consumers = 10;
          };
          notifications.notifications.SMTP = {
            smtp_host = "127.0.0.1";
            smtp_port = 587;
            smtp_sender = "OpenCloud <noreply@pixilie.net>";
            smtp_username = "noreply@pixilie.net";
            smtp_authentication = "plain";
            smtp_encryption = "none";
          };
        };
      };

      systemd.services.opencloud = {
        after = [ "maddy.service" ];
        unitConfig.RequiresMountsFor = [ storageRoot ];
        serviceConfig.ReadWritePaths = [ storageRoot ];
      };

      services.caddy.virtualHosts.${domain}.extraConfig = ''
        reverse_proxy ${cfg.address}:${toString cfg.port}
      '';
    };
}
