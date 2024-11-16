{ ... }:

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

  # Required by swaylock
  security.pam.services.swaylock = { };
}
