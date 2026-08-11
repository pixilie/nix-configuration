{ self, inputs, ... }:
{

  flake.nixosModules.security =
    { config, pkgs, lib, ... }:
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

      # Auto-unlock the login keyring at SDDM login (fixes the Bitwarden
      # password prompt). SDDM delegates PAM to the `login` service, where
      # pam_gnome_keyring (session, order 12600) normally runs AFTER
      # pam_systemd (order 12000) — so systemd starts a LOCKED keyring daemon
      # that grabs org.freedesktop.secrets before PAM can unlock it. Moving
      # gnome_keyring before systemd lets it start+unlock the daemon first and
      # export GNOME_KEYRING_CONTROL, so the autostart just attaches to it.
      security.pam.services.login.rules.session.gnome_keyring.order =
        lib.mkForce 11900;

      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id.indexOf("org.freedesktop.GeoClue2") > -1) {
            return polkit.Result.YES;
          }
        });
      '';
    };
}
