{ ... }:

{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  security.pam.services.swaylock = { };
}
