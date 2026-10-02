{ ... }:
{

  flake.nixosModules.vpsVaultwarden =
    { config, ... }:
    let
      domain = "vault.pixilie.net";
      port = 8222;
    in
    {
      sops.secrets.vaultwarden_admin_token.restartUnits = [ "vaultwarden.service" ];
      sops.secrets.maddy_noreply_password.restartUnits = [ "vaultwarden.service" ];

      sops.templates."vaultwarden.env" = {
        restartUnits = [ "vaultwarden.service" ];
        content = ''
          ADMIN_TOKEN='${config.sops.placeholder.vaultwarden_admin_token}'
          SMTP_PASSWORD=${config.sops.placeholder.maddy_noreply_password}
        '';
      };

      services.vaultwarden = {
        enable = true;
        inherit domain;
        backupDir = "/var/backup/vaultwarden";
        environmentFile = config.sops.templates."vaultwarden.env".path;
        config = {
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = port;
          SIGNUPS_ALLOWED = false;
          INVITATIONS_ALLOWED = true;
          SHOW_PASSWORD_HINT = false;
          SMTP_HOST = "127.0.0.1";
          SMTP_PORT = 587;
          SMTP_SECURITY = "off";
          SMTP_USERNAME = "noreply@pixilie.net";
          SMTP_FROM = "noreply@pixilie.net";
          SMTP_FROM_NAME = "Vaultwarden";
        };
      };

      systemd.services.vaultwarden.after = [ "maddy.service" ];

      services.caddy.virtualHosts.${domain}.extraConfig = ''
        encode zstd gzip
        reverse_proxy 127.0.0.1:${toString port}
      '';
    };
}
