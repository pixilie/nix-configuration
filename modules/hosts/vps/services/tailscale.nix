{ ... }:
{

  flake.nixosModules.vpsTailscale =
    { config, ... }:
    {
      sops.secrets.tailscale_auth_key = { };

      services.tailscale = {
        enable = true;
        openFirewall = true;
        useRoutingFeatures = "client";
        authKeyFile = config.sops.secrets.tailscale_auth_key.path;
        extraUpFlags = [
          "--reset"
          "--hostname=vps"
          "--accept-dns=false"
        ];
        extraSetFlags = [ "--accept-routes" ];
      };
    };
}
