{ ... }:
{

  flake.nixosModules.vpsKalnuMail =
    { config, lib, ... }:
    let
      inherit (import ./_settings.nix) sopsFile;
    in
    {
      sops.secrets.maddy_kalnu_noreply_password = {
        inherit sopsFile;
        owner = config.services.maddy.user;
        restartUnits = [ "maddy-ensure-accounts.service" ];
      };

      services.maddy = {
        localDomains = lib.mkAfter [ "kalnu.fr" ];
        ensureCredentials."noreply@kalnu.fr".passwordFile =
          config.sops.secrets.maddy_kalnu_noreply_password.path;
      };
    };
}
