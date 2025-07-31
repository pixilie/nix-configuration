{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.strongswan
    pkgs.openssl
  ];

  services.strongswan-swanctl.enable = true;

  services.strongswan-swanctl.swanctl = {
    authorities = {
      banquise1.file = "/home/kristen/documents/la-banquise/secrets/cacerts/BanquiseRootCA.cacert.pem";
      banquise2.file = "/home/kristen/documents/la-banquise/secrets/cacerts/BanquiseMachineIssuingCA.cacert.pem";
      banquise3.file = "/home/kristen/documents/la-banquise/secrets/cacerts/BanquiseMachineSubCA.cacert.pem";
      banquise4.file = "/home/kristen/documents/la-banquise/secrets/cacerts/BanquiseUserIssuingCA.cacert.pem";
      banquise5.file = "/home/kristen/documents/la-banquise/secrets/cacerts/BanquiseUserSubCA.cacert.pem";
    };

    connections = {
      banquise = {
        children = {
      banquise = {
        remote_ts = [ "10.0.0.0/9" ];
      };
    };
    local = {
      banquise.auth = "pubkey";
      banquise.certs = [ "/home/kristen/documents/la-banquise/secrets/x509/kristen.couty.pem" ];
    };
    remote = {
      banquise.auth = "pubkey";
      banquise.id = "proxy1.la-banquise.fr";
    };
    remote_addrs = [ "89.168.61.117" ];
    vips = [ "0.0.0.0" ];
      };
    };
  };
}
