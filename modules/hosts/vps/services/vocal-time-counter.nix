{ inputs, ... }:
{

  flake.nixosModules.vpsVocalTimeCounter =
    { config, ... }:
    {
      imports = [ inputs.vocal-time-counter.nixosModules.default ];

      sops.secrets.vocal_time_counter_env.restartUnits = [ "vocal-time-counter.service" ];

      services.vocal-time-counter = {
        enable = true;
        environmentFile = config.sops.secrets.vocal_time_counter_env.path;
      };

      systemd.services.vocal-time-counter.environment = {
        CLIENT_ID = "958049152669999225";
        GUILD_ID = "843864372597358602";
        RUST_LOG = "info";
      };
    };
}
