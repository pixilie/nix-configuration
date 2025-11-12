{ ... }:

{
  networking = {
    hostName = "kristen-nixos";
    networkmanager.enable = true;
    firewall = {
      enable = true;

      allowedTCPPortRanges = [{
        from = 1714;
        to = 1764;
      }];

      allowedUDPPortRanges = [{
        from = 1714;
        to = 1764;
      }];

      allowedUDPPorts = [ 8080 ];
      allowedTCPPorts = [ 8080 ];
    };
  };
}
