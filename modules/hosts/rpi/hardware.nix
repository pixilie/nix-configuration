{ self, inputs, ... }:
{

  flake.nixosModules.rpiHardware =
    { lib, modulesPath, ... }:
    {
      imports = [ (modulesPath + "/installer/sd-card/sd-image-aarch64.nix") ];

      sdImage.compressImage = false;

      boot.supportedFilesystems.zfs = lib.mkForce false;

      hardware.enableRedistributableFirmware = true;

      zramSwap.enable = true;
    };
}
