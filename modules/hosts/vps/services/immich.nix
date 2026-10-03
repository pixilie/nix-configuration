{ ... }:
{

  flake.nixosModules.vpsImmich =
    { config, ... }:
    let
      domain = "photos.pixilie.net";
      cfg = config.services.immich;
    in
    {
      sops.secrets.maddy_noreply_password.restartUnits = [ "immich-server.service" ];

      services.immich = {
        enable = true;
        host = "127.0.0.1";
        port = 2283;
        mediaLocation = "/mnt/nas/immich";
        settings = {
          server.externalDomain = "https://${domain}";
          notifications.smtp = {
            enabled = true;
            from = "Immich <noreply@pixilie.net>";
            transport = {
              host = "127.0.0.1";
              port = 587;
              username = "noreply@pixilie.net";
              password._secret = config.sops.secrets.maddy_noreply_password.path;
            };
          };
        };
      };

      systemd.services.immich-server.after = [ "maddy.service" ];

      services.caddy.virtualHosts.${domain}.extraConfig = ''
        reverse_proxy ${cfg.host}:${toString cfg.port}
      '';
    };
}
