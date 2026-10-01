{ self, inputs, ... }:
{

  flake.nixosModules.vpsConfiguration =
    { pkgs, ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        inputs.sops-nix.nixosModules.sops
        self.nixosModules.vpsHardware
        self.nixosModules.vpsServices
      ];

      networking.hostName = "vps";

      time.timeZone = "Europe/Paris";

      sops = {
        defaultSopsFile = ../../../secrets/vps.yaml;
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };

      services.openssh = {
        enable = true;
        openFirewall = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          AllowUsers = [ "kristen" ];
          AuthenticationMethods = "publickey";
          MaxAuthTries = 3;
        };
      };

      services.fail2ban.enable = true;

      networking.firewall = {
        allowedTCPPorts = [
          80
          443
        ];
        allowedUDPPorts = [ 443 ];
      };

      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_17;
      };

      environment.systemPackages = [ pkgs.sqlite ];

      programs.fish.enable = true;

      users.users.kristen = {
        isNormalUser = true;
        shell = pkgs.fish;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keyFiles = [ ../../../assets/keys/vps.pub ];
      };

      security.sudo.wheelNeedsPassword = false;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.kristen = self.homeModules.vpsHome;
      };

      nix = {
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          trusted-users = [ "kristen" ];
        };

        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };

        optimise.automatic = true;
      };

      system.stateVersion = "26.05";
    };
}
