{ inputs, ... }:
{

  flake.nixosModules.vpsCalendarSyncer =
    { config, ... }:
    let
      domain = "calsync.pixilie.net";
    in
    {
      imports = [ inputs.calendar-syncer.nixosModules.default ];

      # CALSYNC_WEB_PASSWORD=…, GOOGLE_CLIENT_ID=…, GOOGLE_CLIENT_SECRET=…
      sops.secrets.calendar_syncer_env.restartUnits = [ "calendar-syncer.service" ];

      services.calendar-syncer = {
        enable = true;
        listen = "127.0.0.1:8020";
        publicUrl = "https://${domain}";
        environmentFile = config.sops.secrets.calendar_syncer_env.path;
      };

      # Rustical is reached locally at http://127.0.0.1:4000/caldav/
      systemd.services.calendar-syncer = {
        after = [ "rustical.service" ];
        wants = [ "rustical.service" ];
      };

      services.caddy.virtualHosts.${domain}.extraConfig = ''
        encode zstd gzip
        reverse_proxy ${config.services.calendar-syncer.listen}
      '';
    };
}
