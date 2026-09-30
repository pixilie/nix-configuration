{ upkgsBySystem, ... }:
{

  flake.nixosModules.vpsRustical =
    { config, ... }:
    {
      services.rustical = {
        enable = true;
        package = upkgsBySystem.x86_64-linux.rustical;
        settings.http = {
          host = "127.0.0.1";
          port = 4000;
        };
      };

      services.caddy.virtualHosts."rustical.pixilie.net".extraConfig = ''
        encode zstd gzip

        @calino header Origin https://calino.pixilie.net
        header @calino {
          Access-Control-Allow-Origin https://calino.pixilie.net
          Access-Control-Expose-Headers "ETag, DAV, Allow"
          Vary Origin
        }

        @calino_preflight {
          method OPTIONS
          header Origin https://calino.pixilie.net
        }
        handle @calino_preflight {
          header Access-Control-Allow-Methods "GET, PUT, POST, DELETE, PROPFIND, PROPPATCH, REPORT, OPTIONS, MKCOL, MKCALENDAR, COPY, MOVE"
          header Access-Control-Allow-Headers "Authorization, Content-Type, Depth, If-Match, If-None-Match, Destination, Overwrite, Prefer"
          header Access-Control-Max-Age 86400
          respond 204
        }

        reverse_proxy 127.0.0.1:${toString config.services.rustical.settings.http.port}
      '';
    };
}
