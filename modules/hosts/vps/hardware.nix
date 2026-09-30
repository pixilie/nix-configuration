{ inputs, ... }:
{

  flake.nixosModules.vpsHardware =
    { modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
        inputs.disko.nixosModules.disko
      ];

      boot.loader.grub.enable = true;
      boot.initrd.availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "virtio_pci"
        "virtio_scsi"
        "sd_mod"
        "sr_mod"
      ];

      disko.devices.disk.main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            bios = {
              size = "1M";
              type = "EF02";
            };
            boot = {
              size = "1G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };

      zramSwap.enable = true;

      networking.useDHCP = false;
      networking.useNetworkd = true;

      systemd.network.networks."10-wan" = {
        matchConfig.MACAddress = "fa:16:3e:bc:ff:ab";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = false;
        };
        address = [ "2001:41d0:20a:900::162/128" ];
        routes = [
          { Destination = "2001:41d0:20a:900::/64"; }
          {
            Gateway = "2001:41d0:20a:900::";
            GatewayOnLink = true;
          }
        ];
        dns = [ "213.186.33.99" ];
      };
    };
}
