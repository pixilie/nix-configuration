{ ... }:
{

  flake.nixosModules.vpsRustical =
    { ... }:
    let
      bind = "127.0.0.1:4000";
    in
    {
      services.rustical = {
        enable = true;
        settings.http.bind = bind;
      };

      services.caddy.virtualHosts."rustical.pixilie.net".extraConfig = ''
        encode zstd gzip
        reverse_proxy ${bind}
      '';
    };

}
