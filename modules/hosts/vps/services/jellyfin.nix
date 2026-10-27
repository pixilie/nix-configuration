{ ... }:
{

  flake.nixosModules.vpsJellyfin =
    { ... }:
    let
      domain = "media.pixilie.net";
    in
    {
      services.jellyfin.enable = true;

      services.caddy.virtualHosts.${domain}.extraConfig = ''
        reverse_proxy 127.0.0.1:8096
      '';
    };
}
