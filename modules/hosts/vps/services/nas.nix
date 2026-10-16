{ homeNas, ... }:
{

  flake.nixosModules.vpsNas =
    { config, ... }:
    let
      share =
        {
          name,
          owner,
          fileMode,
          dirMode,
          extraOptions ? [ ],
        }:
        {
          device = "//${homeNas.address}/${name}";
          fsType = "cifs";
          options = [
            "credentials=${config.sops.templates."nas-smb-credentials".path}"
            "uid=${owner}"
            "gid=${owner}"
            "file_mode=${fileMode}"
            "dir_mode=${dirMode}"
            "_netdev"
            "nofail"
            "noauto"
            "x-systemd.automount"
            "x-systemd.mount-timeout=30s"
            "x-systemd.after=tailscaled.service"
          ]
          ++ extraOptions;
        };
    in
    {
      sops.secrets.nas_smb_password = { };

      sops.templates."nas-smb-credentials".content = ''
        username=vps
        password=${config.sops.placeholder.nas_smb_password}
      '';

      fileSystems = {
        ${config.services.immich.mediaLocation} = share {
          name = "vps/photos";
          owner = config.services.immich.user;
          fileMode = "0600";
          dirMode = "0700";
        };
        ${config.services.opencloud.settings.storage-users.drivers.decomposed.root} = share {
          name = "vps/cloud";
          owner = config.services.opencloud.user;
          fileMode = "0600";
          dirMode = "0700";
          extraOptions = [ "mfsymlinks" ];
        };
      };
    };
}
