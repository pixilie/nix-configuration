{ ... }:
{

  flake.nixosModules.rpiKalnuNtfy =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (import ./_settings.nix) sopsFile ntfyListen;
      state = "/var/lib/ntfy-kalnu";

      configFile = (pkgs.formats.yaml { }).generate "ntfy-kalnu.yml" {
        base-url = "https://ntfy.kalnu.fr";
        listen-http = ntfyListen;
        behind-proxy = true;
        auth-file = "${state}/user.db";
        auth-default-access = "deny-all";
        enable-login = true;
        cache-file = "${state}/cache-file.db";
        attachment-cache-dir = "${state}/attachments";
        upstream-base-url = "https://ntfy.sh";
      };
    in
    {
      sops.secrets.ntfy_kalnu_env = {
        inherit sopsFile;
        restartUnits = [ "ntfy-kalnu.service" ];
      };

      systemd.services.ntfy-kalnu = {
        description = "ntfy de Kalnu (alertes du projet)";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          DynamicUser = true;
          User = "ntfy-kalnu";
          Group = "ntfy-kalnu";
          ExecStart = "${lib.getExe' pkgs.ntfy-sh "ntfy"} serve -c ${configFile}";
          StateDirectory = "ntfy-kalnu";
          EnvironmentFile = config.sops.secrets.ntfy_kalnu_env.path;
          Restart = "on-failure";
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
        };
      };

      services.caddy.virtualHosts."ntfy.kalnu.fr".extraConfig = ''
        reverse_proxy ${ntfyListen}
      '';
    };
}
