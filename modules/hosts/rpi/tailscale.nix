{ homeNas, ... }:
{

  flake.nixosModules.rpiTailscale =
    { config, ... }:
    {
      sops.secrets.tailscale_auth_key = { };

      services.tailscale = {
        enable = true;
        openFirewall = true;
        useRoutingFeatures = "server";
        authKeyFile = config.sops.secrets.tailscale_auth_key.path;
        extraUpFlags = [
          "--reset"
          "--hostname=rpi"
          "--accept-dns=false"
        ];
        extraSetFlags = [ "--advertise-routes=${homeNas.address}/32" ];
      };
    };
}
