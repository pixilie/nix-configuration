{ ... }:
{

  flake.nixosModules.vpsStorageBox =
    { config, lib, ... }:
    let
      box = "u693820";

      subAccounts = {
        immich = {
          sub = "sub1";
          owner = config.services.immich.user;
          extraOptions = [ ];
        };
        opencloud = {
          sub = "sub2";
          owner = config.services.opencloud.user;
          extraOptions = [
            "mfsymlinks"
            "nobrl"
          ];
        };
      };

      user = account: "${box}-${account.sub}";
    in
    {
      sops.secrets = lib.mapAttrs' (
        name: _: lib.nameValuePair "storagebox_${name}_password" { }
      ) subAccounts;

      sops.templates = lib.mapAttrs' (
        name: account:
        lib.nameValuePair "storagebox-${name}-credentials" {
          content = ''
            username=${user account}
            password=${config.sops.placeholder."storagebox_${name}_password"}
          '';
        }
      ) subAccounts;

      fileSystems = lib.mapAttrs' (
        name: account:
        lib.nameValuePair "/mnt/storagebox/${name}" {
          device = "//${user account}.your-storagebox.de/${user account}";
          fsType = "cifs";
          options = [
            "credentials=${config.sops.templates."storagebox-${name}-credentials".path}"
            "seal"
            "uid=${account.owner}"
            "gid=${account.owner}"
            "file_mode=0600"
            "dir_mode=0700"
            "_netdev"
            "nofail"
            "noauto"
            "x-systemd.automount"
            "x-systemd.mount-timeout=30s"
          ]
          ++ account.extraOptions;
        }
      ) subAccounts;
    };
}
