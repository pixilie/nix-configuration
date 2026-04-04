{ ... }:

{
  networking = {
    hostName = "kristen-nixos";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedUDPPorts = [ 8080 53317 ];
      allowedTCPPorts = [ 8080 53317 ];
    };
  };
}
