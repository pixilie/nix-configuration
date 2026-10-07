{ self, inputs, ... }:
{

  flake.nixosModules.laptopConfiguration =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        self.nixosModules.laptopHardware
        self.nixosModules.audio
        self.nixosModules.bluetooth
        self.nixosModules.security
        self.nixosModules.network
        self.nixosModules.powerManagement
        self.nixosModules.sddm
        self.nixosModules.virtualisation
        self.nixosModules.docker
        self.nixosModules.steam
        self.nixosModules.nix_ld
        self.nixosModules.specialPackages
        self.nixosModules.nh
        self.nixosModules.sway
        self.nixosModules.veila
      ];

      networking.hostName = "kristen-nixos";

      services.automatic-timezoned.enable = true;

      services.geoclue2 = {
        enable = true;
        enableDemoAgent = true;
        geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
        submissionUrl = "https://beacondb.net/v2/geosubmit";
        submitData = true;
      };

      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      nix.optimise.automatic = true;

      zramSwap.enable = true;

      boot = {
        kernelParams = [ "quiet" ];
        binfmt.emulatedSystems = [ "aarch64-linux" ];
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
          systemd-boot.configurationLimit = 10;
          timeout = 0;
        };
      };

      programs.fish.enable = true;

      users.users.kristen = {
        isNormalUser = true;
        shell = pkgs.fish;
        extraGroups = [
          "wheel"
          "networkmanager"
          "sway"
          "input"
          "gamemode"
          "libvirtd"
          "dialout"
        ];
      };

      system = {
        autoUpgrade.enable = true;
        autoUpgrade.flake = "github:pixilie/nix-configuration#laptop";
        autoUpgrade.upgrade = false;
        autoUpgrade.allowReboot = true;
        autoUpgrade.rebootWindow = {
          lower = "02:00";
          upper = "06:00";
        };
        stateVersion = "26.05";
      };

      services.thermald.enable = true;
      services.gvfs.enable = true;
      services.udisks2.enable = true;
      services.devmon.enable = true;

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];

        trusted-users = [ "kristen" ];

        substituters = [ "https://nix-community.cachix.org" ];

        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };
}
