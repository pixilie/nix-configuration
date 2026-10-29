{ ... }:
{

  flake.nixosModules.vpsPufferpanel =
    { lib, pkgs, ... }:
    let
      domain = "games.pixilie.net";
      webAddress = "127.0.0.2";
      web = "${webAddress}:8085";
      proxyAddress = "127.0.0.3";
      sftpPort = 5657;
      gamePorts = {
        from = 25565;
        to = 25575;
      };
      steamPorts = {
        from = 27015;
        to = 27030;
      };
    in
    {
      services.pufferpanel = {
        enable = true;
        package = pkgs.buildFHSEnv {
          name = "pufferpanel-fhs";
          runScript = lib.getExe pkgs.pufferpanel;
          multiArch = true;
          targetPkgs =
            p: with p; [
              icu
              openssl
              zlib
            ];
          multiPkgs =
            p: with p; [
              zlib
              stdenv.cc.cc.lib
            ];
        };
        extraPackages = with pkgs; [
          bash
          curl
          gawk
          gnutar
          gzip
          unzip
        ];
        environment = {
          PUFFER_WEB_HOST = web;
          PUFFER_DAEMON_SFTP_HOST = "0.0.0.0:${toString sftpPort}";
          PUFFER_PANEL_REGISTRATIONENABLED = "false";
          PUFFER_PANEL_SETTINGS_MASTERURL = "https://${domain}";
          PUFFER_PANEL_SETTINGS_COMPANYNAME = "Pixilie";
        };
      };

      environment.systemPackages = [ pkgs.pufferpanel ];

      systemd.services.pufferpanel.serviceConfig = {
        ExecPaths = [ "/var/lib/private/pufferpanel" ];
        MemoryHigh = "5G";
        MemoryMax = "6G";
        CPUQuota = "400%";
        IPAddressDeny = [
          "localhost"
          "link-local"
          "multicast"
        ];
        IPAddressAllow = [
          webAddress
          proxyAddress
          "127.0.0.53"
          "127.0.0.54"
        ];
      };

      networking.firewall = {
        allowedTCPPorts = [ sftpPort ];
        allowedTCPPortRanges = [
          gamePorts
          steamPorts
        ];
        allowedUDPPortRanges = [
          gamePorts
          steamPorts
        ];
      };

      services.caddy.virtualHosts.${domain}.extraConfig = ''
        encode zstd gzip
        reverse_proxy ${web} {
          transport http {
            local_address ${proxyAddress}
          }
        }
      '';
    };
}
