{ ... }:
{

  flake.nixosModules.vpsPgadmin =
    { config, lib, ... }:
    let
      rolePasswords = {
        kalnu = "kalnu_postgres_password";
        coach = "garmin_postgres_password";
      };
      upstream = "127.0.0.1:${toString config.services.pgadmin.port}";
    in
    {
      sops.secrets = {
        pgadmin_password.owner = "pgadmin";
      }
      // lib.mapAttrs' (
        _: secret:
        lib.nameValuePair secret {
          owner = "postgres";
          restartUnits = [ "postgresql-role-passwords.service" ];
        }
      ) rolePasswords;

      services.pgadmin = {
        enable = true;
        port = 5051;
        initialEmail = "kristen@pixilie.net";
        initialPasswordFile = config.sops.secrets.pgadmin_password.path;
        settings.DEFAULT_SERVER = "127.0.0.1";
      };

      systemd.services.postgresql-role-passwords = {
        description = "Set PostgreSQL role passwords from sops";
        wantedBy = [ "multi-user.target" ];
        requires = [ "postgresql.target" ];
        after = [ "postgresql.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = "postgres";
        };
        script = lib.concatStrings (
          lib.mapAttrsToList (role: secret: ''
            ${config.services.postgresql.package}/bin/psql -q -v ON_ERROR_STOP=1 <<'SQL'
            \set pw `cat ${config.sops.secrets.${secret}.path}`
            ALTER ROLE ${role} PASSWORD :'pw';
            SQL
          '') rolePasswords
        );
      };

      services.caddy.virtualHosts = {
        "pgadmin.pixilie.net".extraConfig = ''
          encode zstd gzip
          reverse_proxy ${upstream}
        '';
        "pgadmin.kalnu.pixilie.net".extraConfig = ''
          redir https://pgadmin.pixilie.net{uri} 308
        '';
      };
    };
}
