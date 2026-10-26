{ ... }:
{

  flake.nixosModules.vpsCalino =
    { pkgs, lib, ... }:
    let
      calino = pkgs.callPackage ../_packages/calino.nix { siteUrl = "https://calino.pixilie.net"; };
      proxyPort = 8081;
    in
    {
      systemd.services.calino-proxy = {
        description = "Calino CORS proxy for webcal feeds";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        environment = {
          PORT = toString proxyPort;
          ALLOWED_ORIGINS = "https://calino.pixilie.net";
          ALLOWED_TARGETS = "zeus.ionis-it.com";
        };
        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.nodejs_22} ${calino}/share/calino/proxy/server.mjs";
          DynamicUser = true;
          Restart = "on-failure";
          NoNewPrivileges = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
          PrivateDevices = true;
          MemoryMax = "128M";
        };
      };

      services.caddy.virtualHosts."calino.pixilie.net".extraConfig = ''
        encode zstd gzip

        handle_path /proxy/* {
          @no_origin not header Origin *
          request_header @no_origin Origin https://calino.pixilie.net
          reverse_proxy 127.0.0.1:${toString proxyPort}
        }

        handle {
          root * ${calino}/share/calino/web
          try_files {path} /index.html
          file_server

          header {
            X-Frame-Options "SAMEORIGIN"
            X-Content-Type-Options "nosniff"
            Referrer-Policy "strict-origin-when-cross-origin"
            Permissions-Policy "camera=(), microphone=(), geolocation=(), payment=(), usb=(), interest-cohort=()"
            -Server
          }

          @assets path /assets/*
          header @assets Cache-Control "public, immutable"
        }
      '';
    };
}
