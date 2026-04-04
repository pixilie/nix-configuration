{ ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
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
}
