{ ... }:
{

  flake.nixosModules.vpsPgadmin =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      rolePasswords = {
        kalnu = "kalnu_postgres_password";
        coach = "garmin_postgres_password";
        alexandre = "alexandre_postgres_password";
        kristen = "kristen_postgres_password";
      };

      appRoles = {
        kalnu = [ "kalnu" ];
        garmin_coach = [ "coach" ];
        postgres = [ ];
      };

      people = {
        alexandre = {
          kalnu = "kalnu";
        };
        kristen = {
          kalnu = "kalnu";
          garmin_coach = "coach";
        };
      };

      databaseAccess = lib.mapAttrs (
        db: roles: roles ++ lib.attrNames (lib.filterAttrs (_: dbs: dbs ? ${db}) people)
      ) appRoles;

      psql = "${config.services.postgresql.package}/bin/psql";
      quote = role: ''"${role}"'';

      accessSql = pkgs.writeText "postgresql-access.sql" (
        lib.concatStrings (
          lib.mapAttrsToList (
            db: roles:
            ''
              REVOKE CONNECT ON DATABASE ${quote db} FROM PUBLIC;
              DO $$
              DECLARE r record;
              BEGIN
                FOR r IN SELECT rolname FROM pg_roles WHERE NOT rolsuper AND rolname !~ '^pg_' LOOP
                  EXECUTE format('REVOKE CONNECT ON DATABASE %I FROM %I', '${db}', r.rolname);
                END LOOP;
              END $$;
            ''
            + lib.optionalString (roles != [ ]) ''
              GRANT CONNECT ON DATABASE ${quote db} TO ${lib.concatMapStringsSep ", " quote roles};
            ''
          ) databaseAccess
          ++ lib.mapAttrsToList (
            person: dbs:
            ''
              ALTER ROLE ${quote person} RESET role;
            ''
            + lib.concatStrings (
              lib.mapAttrsToList (db: role: ''
                GRANT ${quote role} TO ${quote person};
                ALTER ROLE ${quote person} IN DATABASE ${quote db} SET role = ${quote role};
              '') dbs
            )
          ) people
        )
      );

      upstream = "127.0.0.1:${toString config.services.pgadmin.port}";
    in
    {
      sops.secrets = {
        pgadmin_password.owner = "pgadmin";
        maddy_noreply_password.restartUnits = [ "pgadmin.service" ];
      }
      // lib.mapAttrs' (
        _: secret:
        lib.nameValuePair secret {
          owner = "postgres";
          restartUnits = [ "postgresql-access.service" ];
        }
      ) rolePasswords;

      services.postgresql.ensureUsers = map (name: { inherit name; }) (lib.attrNames people);

      services.pgadmin = {
        enable = true;
        port = 5051;
        initialEmail = "kristen@pixilie.net";
        initialPasswordFile = config.sops.secrets.pgadmin_password.path;
        settings.DEFAULT_SERVER = "127.0.0.1";
        emailServer = {
          enable = true;
          address = "127.0.0.1";
          port = 587;
          username = "noreply@pixilie.net";
          sender = "noreply@pixilie.net";
          passwordFile = config.sops.secrets.maddy_noreply_password.path;
        };
      };

      systemd.services.postgresql-access = {
        description = "Apply PostgreSQL role passwords and database access";
        wantedBy = [ "multi-user.target" ];
        requires = [ "postgresql-setup.service" ];
        after = [ "postgresql-setup.service" ];
        restartTriggers = [ accessSql ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = "postgres";
        };
        script =
          lib.concatStrings (
            lib.mapAttrsToList (role: secret: ''
              ${psql} -q -v ON_ERROR_STOP=1 <<'SQL'
              \set pw `cat ${config.sops.secrets.${secret}.path}`
              ALTER ROLE ${quote role} PASSWORD :'pw';
              SQL
            '') rolePasswords
          )
          + ''
            ${psql} -q -v ON_ERROR_STOP=1 -f ${accessSql}
          '';
      };

      services.caddy.virtualHosts = {
        "pgadmin.pixilie.net".extraConfig = ''
          encode zstd gzip
          reverse_proxy ${upstream}
        '';
      };
    };
}
