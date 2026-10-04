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
          ];
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
      };
    };
}
