{ pkgs, ... }:

{
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;

    settings = {
      daemonize = true;
      ignore-empty-password = true;
      show-failed-attempts = true;
      screenshots = true;
      clock = true;
      indicator = true;

      font = "Noto Sans";

      indicator-radius = 100;
      indicator-thickness = 7;

      effect-blur = "7x5";
      effect-vignette = "0.5:0.5";

      ring-color = "61AFEF";
      key-hl-color = "880033";
      line-color = "00000000";
      inside-color = "00000088";
      separator-color = "00000000";
    };
  };
}
