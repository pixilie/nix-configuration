{ ... }:

{
  networking = {
    hostName = "kristen-nixos";
    networkmanager.enable = true;
    hosts = { "10.45.3.4" = [ "printer.epita" ]; };
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
    };
  };
}
