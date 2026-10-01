{ inputs, ... }:
{

  flake.nixosModules.vpsCalendarSyncer =
    { config, ... }:
    let
      domain = "calsync.pixilie.net";
    in
    {
      imports = [ inputs.calendar-syncer.nixosModules.default ];

      sops.secrets.calendar_syncer_env.restartUnits = [ "calendar-syncer.service" ];

      services.calendar-syncer = {
        enable = true;
        listen = "127.0.0.1:8020";
        publicUrl = "https://${domain}";
        environmentFile = config.sops.secrets.calendar_syncer_env.path;
      };

      systemd.services.calendar-syncer = {
        environment.CALSYNC_WEB_USER = "kristen";
        after = [ "rustical.service" ];
        wants = [ "rustical.service" ];
      };

      services.caddy.virtualHosts.${domain}.extraConfig = ''
        encode zstd gzip
        reverse_proxy ${config.services.calendar-syncer.listen}
      '';
    };
}
