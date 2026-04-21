{ self, inputs, ... }: {

  flake.nixosModules.network = { pkgs, ... }: {

    networking = {
      networkmanager.enable = true;

      firewall = {
        enable = true;
        allowedUDPPorts = [ 8080 53317 ];
        allowedTCPPorts = [ 8080 53317 ];
        allowedTCPPortRanges = [{
          from = 1714;
          to = 1764;
        }];
        allowedUDPPortRanges = [{
          from = 1714;
          to = 1764;
        }];
      };
    };
  };
}
