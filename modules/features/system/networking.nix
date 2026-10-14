{ self, inputs, ... }: {

  flake.nixosModules.network = { pkgs, ... }: {

    programs.wireshark = {
      enable = true;
      dumpcap.enable = true;
      usbmon.enable = true;
      package = pkgs.wireshark;
    };

    networking = {
      networkmanager.enable = true;

      firewall = {
        enable = true;
        allowedUDPPorts = [ 53317 ];
        allowedTCPPorts = [ 53317 ];
      };
    };
  };
}
