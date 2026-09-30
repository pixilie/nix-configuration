{ self, inputs, ... }:
{

  flake.nixosModules.rpiMonitoring =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        defaultSopsFile = ../../../secrets/rpi.yaml;
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        secrets.kuma_push_url = { };
      };

      services.uptime-kuma = {
        enable = true;
        settings = {
          HOST = "127.0.0.1";
          PORT = "3001";
          TZ = "Europe/Paris";
        };
      };

      services.caddy = {
        enable = true;
        virtualHosts."status.pixilie.net".extraConfig = ''
          encode zstd gzip
          redir / /status/services 302
          reverse_proxy 127.0.0.1:3001
        '';
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
      networking.firewall.allowedUDPPorts = [ 443 ];

      systemd.services.kuma-heartbeat = {
        description = "Heartbeat to the VPS Uptime Kuma";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          DynamicUser = true;
          LoadCredential = "push-url:${config.sops.secrets.kuma_push_url.path}";
        };
        script = ''
          ${lib.getExe pkgs.curl} -fsS -m 10 -o /dev/null "$(< "$CREDENTIALS_DIRECTORY/push-url")"
        '';
      };

      systemd.timers.kuma-heartbeat = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "30s";
          OnUnitActiveSec = "30s";
          AccuracySec = "1s";
        };
      };
    };
}
