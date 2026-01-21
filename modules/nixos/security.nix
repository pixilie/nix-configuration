{ ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
  # programs.ssh.startAgent = true;

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
}
