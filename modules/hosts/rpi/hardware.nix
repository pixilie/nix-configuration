{ self, inputs, ... }:
{

  flake.nixosModules.rpiHardware =
    { lib, modulesPath, ... }:
    {
      imports = [ (modulesPath + "/installer/sd-card/sd-image-aarch64.nix") ];

      sdImage.compressImage = false;

      boot.supportedFilesystems.zfs = lib.mkForce false;

      hardware.enableRedistributableFirmware = true;
      hardware.wirelessRegulatoryDatabase = true;

      boot.extraModprobeConfig = ''
        options cfg80211 ieee80211_regdom="FR"
      '';

      zramSwap.enable = true;
    };
}
