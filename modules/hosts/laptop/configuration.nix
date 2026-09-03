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
      ];

      networking.hostName = "kristen-nixos";

      # Localisation services
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

      # Garbage collection is handled by programs.nh.clean (see nh.nix),
      # so the native nix.gc.automatic is left disabled to avoid conflict.
      nix.optimise.automatic = true;

      zramSwap.enable = true;

      # Boot settings
      boot = {
        kernelParams = [ "quiet" ];
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
          systemd-boot.configurationLimit = 10;
          timeout = 0;
        };
      };

      # User related settings
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

      # System related settings
      system = {
        autoUpgrade.enable = true;
        autoUpgrade.flake = "github:pixilie/nix-configuration#laptop";
        autoUpgrade.upgrade = false;
        autoUpgrade.allowReboot = true;
        autoUpgrade.rebootWindow = {
          lower = "02:00";
          upper = "06:00";
        };
        stateVersion = "25.11";
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
