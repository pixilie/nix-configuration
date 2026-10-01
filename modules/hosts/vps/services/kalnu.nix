{ inputs, ... }:
{

  flake.nixosModules.vpsKalnu =
    { config, pkgs, ... }:
    let
      backend = "127.0.0.1:${toString config.services.kalnu.port}";

      # BRouter (routage vélo de l'éditeur GPX) : absent de nixpkgs, et le module kalnu ne le gère pas.
      # Release officielle, même version et même hash que server/brouter/Dockerfile de kalnu.
      brouterVersion = "1.7.10";
      brouterJar =
        pkgs.runCommand "brouter-${brouterVersion}-jar" { nativeBuildInputs = [ pkgs.unzip ]; }
          ''
            unzip -q ${
              pkgs.fetchurl {
                url = "https://github.com/abrensch/brouter/releases/download/v${brouterVersion}/brouter-${brouterVersion}.zip";
                sha256 = "023fec3ba997758e8cd7ab9e1bae52e962af3f00b57683e3de86b84ffad01532";
              }
            }
            install -Dm444 brouter-${brouterVersion}/brouter-${brouterVersion}-all.jar $out/brouter.jar
          '';
      # Profils Kalnu + lookups.dat : suivent les mises à jour de l'input kalnu.
      brouterProfiles = "${inputs.kalnu}/server/brouter/profiles";
      brouterState = "/var/lib/kalnu-brouter";
    in
    {
      imports = [ inputs.kalnu.nixosModules.default ];

      sops.secrets.kalnu_env = {
        owner = config.services.kalnu.user;
        restartUnits = [ "kalnu.service" ];
      };

      services.kalnu = {
        enable = true;
        domain = "kalnu.pixilie.net";
        environmentFile = config.sops.secrets.kalnu_env.path;
        settings = {
          BROUTER_URL = "http://127.0.0.1:17777";
          # E-mails de réinitialisation du mot de passe : maddy local (submission 127.0.0.1:587, sans TLS),
          # compte noreply. Le mot de passe est celui de maddy, passé en credential systemd (ci-dessous).
          SMTP_HOST = "127.0.0.1";
          SMTP_PORT = 587;
          SMTP_SECURITY = "none";
          SMTP_USER = "noreply@pixilie.net";
          SMTP_PASSWORD_FILE = "/run/credentials/kalnu.service/smtp_password";
          MAIL_FROM = "Kalnu <noreply@pixilie.net>";
        };
      };

      # Le secret appartient à maddy : systemd en donne une copie lisible au seul service kalnu.
      systemd.services.kalnu = {
        after = [ "maddy.service" ];
        serviceConfig.LoadCredential = "smtp_password:${config.sops.secrets.maddy_noreply_password.path}";
      };
      sops.secrets.maddy_noreply_password.restartUnits = [ "kalnu.service" ];

      systemd.services.kalnu-brouter = {
        description = "BRouter — routage vélo de l'éditeur GPX Kalnu";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          DynamicUser = true;
          StateDirectory = "kalnu-brouter kalnu-brouter/segments4 kalnu-brouter/custom";
          ExecStart =
            "${pkgs.jre_headless}/bin/java -Xmx512m -Xms128m -DmaxRunningTime=30 "
            + "-cp ${brouterJar}/brouter.jar btools.server.RouteServer "
            + "${brouterState}/segments4 ${brouterProfiles} ${brouterState}/custom 17777 4 127.0.0.1";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };

      # Tuiles .rd5 : mise à jour hebdomadaire et conditionnelle, rollback si l'itinéraire de test échoue.
      systemd.services.kalnu-brouter-segments = {
        description = "Mise à jour des segments BRouter (Kalnu)";
        after = [
          "network-online.target"
          "kalnu-brouter.service"
        ];
        wants = [
          "network-online.target"
          "kalnu-brouter.service"
        ];
        path = with pkgs; [
          bash
          curl
          coreutils
          gnugrep
          systemd
        ];
        environment = {
          BROUTER_SEGMENTS_DIR = "${brouterState}/segments4";
          BROUTER_RELOAD_CMD = "systemctl restart kalnu-brouter";
          BROUTER_CACHE_DIR = "/var/cache/kalnu-brouter";
        };
        serviceConfig = {
          Type = "oneshot";
          CacheDirectory = "kalnu-brouter";
        };
        script = "bash ${inputs.kalnu}/server/brouter/update_segments.sh";
      };

      systemd.timers.kalnu-brouter-segments = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          # Aussi 5 min après l'activation du timer (déploiement, boot) : remplit les tuiles dès le
          # premier déploiement ; ensuite le script sort aussitôt (garde de 6 jours, cf. .last_update).
          OnActiveSec = "5min";
          OnCalendar = "Thu 04:30";
          RandomizedDelaySec = "2h";
          Persistent = true;
        };
      };

      services.caddy.virtualHosts = {
        "kalnu.pixilie.net".extraConfig = ''
          reverse_proxy ${backend}
        '';
        "api.kalnu.pixilie.net".extraConfig = ''
          reverse_proxy ${backend}
        '';
      };
    };
}
