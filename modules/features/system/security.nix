{ self, inputs, ... }:
{

  flake.nixosModules.security =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      services.openssh = {
        enable = true;
        openFirewall = false;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
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

      security.pam.services.login.rules.session.gnome_keyring.order = lib.mkForce 11900;

      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id.indexOf("org.freedesktop.GeoClue2") > -1) {
            return polkit.Result.YES;
          }
        });
      '';
    };
}
