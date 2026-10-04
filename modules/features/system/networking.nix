{ self, inputs, ... }: {

  flake.nixosModules.network = { pkgs, ... }: {

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
