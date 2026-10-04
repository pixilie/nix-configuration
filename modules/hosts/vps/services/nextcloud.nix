{ ... }:
{

  flake.nixosModules.vpsNextcloud =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      domain = "cloud.pixilie.net";
      port = 8180;
      dataDir = "${config.services.nextcloud.datadir}/data";

      unusedApps = [
        "activity"
        "app_api"
        "circles"
        "comments"
        "contactsinteraction"
        "dashboard"
        "federation"
        "files_reminders"
        "firstrunwizard"
        "logreader"
        "nextcloud_announcements"
        "office"
        "photos"
        "recommendations"
        "related_resources"
        "sharebymail"
        "support"
        "survey_client"
        "systemtags"
        "updatenotification"
        "user_status"
        "weather_status"
        "webhook_listeners"
      ];
    in
    {
      sops.secrets.nextcloud_admin_password = { };
      sops.secrets.maddy_noreply_password.restartUnits = [ "phpfpm-nextcloud.service" ];

      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud34;
        hostName = domain;
        https = true;
        maxUploadSize = "16G";
        appstoreEnable = false;
        phpOptions."opcache.interned_strings_buffer" = "32";
        database.createLocally = true;
        config = {
          dbtype = "pgsql";
          adminuser = "kristen";
          adminpassFile = config.sops.secrets.nextcloud_admin_password.path;
        };
        secrets.mail_smtppassword = config.sops.secrets.maddy_noreply_password.path;
        settings = {
          overwriteprotocol = "https";
          trusted_proxies = [ "127.0.0.1" ];
          default_phone_region = "FR";
          defaultapp = "files";
          maintenance_window_start = 2;
          mail_smtpmode = "smtp";
          mail_smtphost = "127.0.0.1";
          mail_smtpport = 587;
          mail_smtpauth = true;
          mail_smtpname = "noreply@pixilie.net";
          mail_from_address = "noreply";
          mail_domain = "pixilie.net";
        };
      };

      systemd.services.nextcloud-setup = {
        unitConfig.RequiresMountsFor = [ dataDir ];
        script = lib.mkAfter ''
          $OCC_BIN app:disable ${lib.concatStringsSep " " unusedApps}
        '';
      };

      systemd.services.nextcloud-cron.unitConfig.RequiresMountsFor = [ dataDir ];

      services.nginx.virtualHosts.${domain}.listen = [
        {
          addr = "127.0.0.1";
          inherit port;
        }
      ];

      services.caddy.virtualHosts.${domain}.extraConfig = ''
        reverse_proxy 127.0.0.1:${toString port}
      '';
    };
}
