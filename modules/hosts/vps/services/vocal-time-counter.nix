{ inputs, ... }:
{

  flake.nixosModules.vpsVocalTimeCounter =
    { config, pkgs, ... }:
    let
      bot = pkgs.rustPlatform.buildRustPackage {
        pname = "vocal-time-counter";
        version = "0.1.0";
        src = inputs.vocal-time-counter;
        cargoLock.lockFile = "${inputs.vocal-time-counter}/Cargo.lock";
        nativeBuildInputs = [ pkgs.pkg-config ];
        buildInputs = [ pkgs.openssl ];
        meta.mainProgram = "vocal-time-counter";
      };
    in
    {
      sops.secrets.vocal_time_counter_env.restartUnits = [ "vocal-time-counter.service" ];

      systemd.services.vocal-time-counter = {
        description = "Discord voice time counter bot";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        environment = {
          CLIENT_ID = "958049152669999225";
          GUILD_ID = "843864372597358602";
          RUST_LOG = "info";
        };
        serviceConfig = {
          ExecStart = pkgs.lib.getExe bot;
          EnvironmentFile = config.sops.secrets.vocal_time_counter_env.path;
          DynamicUser = true;
          StateDirectory = [
            "vocal-time-counter"
            "vocal-time-counter/data"
          ];
          WorkingDirectory = "/var/lib/vocal-time-counter";
          Restart = "always";
          NoNewPrivileges = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
          PrivateDevices = true;
        };
      };
    };
}
