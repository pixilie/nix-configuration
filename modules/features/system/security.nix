{ self, inputs, ... }:
{

  flake.nixosModules.security =
    { config, pkgs, ... }:
    {

      services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
      };

      # gpg-agent for GPG only. SSH keys are handled by gcr-ssh-agent
      # (enabled by default via gnome-keyring), which avoids the pinentry
      # popup gpg-agent shows when adding ssh keys to its keystore.
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = false;
      };

      services.logind = {
        settings.Login = {
          HandleLidSwitch = "suspend";
          IdleAction = "lock";
          HandlePowerKey = "lock";
          HandlePowerKeyLongPress = "suspend";
        };
      };

      services.gnome.gnome-keyring.enable = true;
      security.pam.services.sddm.enableGnomeKeyring = true;

      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id.indexOf("org.freedesktop.GeoClue2") > -1) {
            return polkit.Result.YES;
          }
        });
      '';
    };
}
