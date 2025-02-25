{ lib, ... }:

{
  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
  programs.ssh.startAgent = true;

  # How power button handle presses
  services.logind = {
    lidSwitch = "suspend";
    extraConfig = lib.generators.toKeyValue { } {
      IdleAction = "lock";
      HandlePowerKey = "lock";
      HandlePowerKeyLongPress = "suspend";
    };
  };

  # Required by swaylock
  security.pam.services.swaylock = { };
}
