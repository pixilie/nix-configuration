{ ... }:
{

  flake.nixosModules.vpsMiniflux =
    { config, ... }:
    let
      domain = "rss.pixilie.net";
      cfg = config.services.miniflux;
    in
    {
      sops.secrets.miniflux_admin_password = { };

      sops.templates."miniflux-admin.env" = {
        restartUnits = [ "miniflux.service" ];
        content = ''
          ADMIN_USERNAME=kristen
          ADMIN_PASSWORD=${config.sops.placeholder.miniflux_admin_password}
        '';
      };

      services.miniflux = {
        enable = true;
        adminCredentialsFile = config.sops.templates."miniflux-admin.env".path;
        config = {
          BASE_URL = "https://${domain}";
          LISTEN_ADDR = "127.0.0.1:8080";
          TRUSTED_REVERSE_PROXY_NETWORKS = "127.0.0.1/32";
        };
      };

      services.caddy.virtualHosts.${domain}.extraConfig = ''
        encode zstd gzip
        reverse_proxy ${cfg.config.LISTEN_ADDR}
      '';
    };
}
