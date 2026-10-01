{ inputs, upkgsBySystem, ... }:
{

  flake.nixosModules.vpsRustical =
    { ... }:
    let
      bind = "127.0.0.1:4000";
    in
    {
      disabledModules = [ "services/web-apps/rustical.nix" ];
      imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/rustical.nix" ];

      services.rustical = {
        enable = true;
        package = upkgsBySystem.x86_64-linux.rustical;
        settings.http.bind = bind;
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

        reverse_proxy ${bind}
      '';
    };
}
