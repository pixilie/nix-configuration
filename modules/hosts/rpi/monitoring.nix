{ inputs, ... }:
{

  flake.nixosModules.rpiMonitoring =
    { config, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      sops = {
        defaultSopsFile = ../../../secrets/rpi.yaml;
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        secrets.beszel_agent_env.restartUnits = [ "beszel-agent.service" ];
      };

      services.beszel.agent = {
        enable = true;
        environment = {
          HUB_URL = "https://beszel.pixilie.net";
          KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICCgncTKfW/Obw8dipvTvisdQ4Qb1HEfWF5vEip2QVdx";
        };
        environmentFile = config.sops.secrets.beszel_agent_env.path;
      };

      services.caddy.enable = true;

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
      networking.firewall.allowedUDPPorts = [ 443 ];
    };
}
