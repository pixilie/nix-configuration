{ self, inputs, ... }:
{

  flake.nixosModules.rpiConfiguration =
    { pkgs, ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        self.nixosModules.rpiHardware
      ];

      networking.hostName = "rpi";
      networking.networkmanager.enable = true;

      time.timeZone = "Europe/Paris";

      services.openssh = {
        enable = true;
        openFirewall = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };

      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
        publish = {
          enable = true;
          addresses = true;
        };
      };

      programs.fish.enable = true;

      users.users.kristen = {
        isNormalUser = true;
        shell = pkgs.fish;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        openssh.authorizedKeys.keyFiles = [ ../../../assets/keys/rpi.pub ];
      };

      security.sudo.wheelNeedsPassword = false;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.kristen = self.homeModules.rpiHome;
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
