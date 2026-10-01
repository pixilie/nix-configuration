{ self, ... }:
{

  flake.nixosModules.vpsServices = {
    imports = [
      self.nixosModules.vpsWakapi
      self.nixosModules.vpsRustical
      self.nixosModules.vpsCalino
      self.nixosModules.vpsBeszel
      self.nixosModules.vpsVocalTimeCounter
      self.nixosModules.vpsKalnu
      self.nixosModules.vpsGarminCoach
      self.nixosModules.vpsCalendarSyncer
      self.nixosModules.vpsPgadmin
    ];

    services.caddy.enable = true;

    services.postgresqlBackup = {
      enable = true;
      compression = "zstd";
      startAt = "*-*-* 04:00:00";
    };
  };
}
