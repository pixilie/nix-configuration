{pkgs, ...}:

{
  programs.swaylock = {
    enable = true;

    settings = {
      daemonize = true;
      ignore-empty-password = true;
      show-failed-attempts = true;

      image = toString ../../assets/wallpaper.png;

      indicator-y-position = -100;
      indicator-x-position = 100;
    };
  };
}
