{ ... }:
let
  files = [ "org.gnome.Nautilus.desktop" ];
  browser = [ "firefox.desktop" ];
  images = [ "imv.desktop" ];
  terminal = [ "Alacritty.desktop" ];
in {
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "inode/directory" = files;

      "application/pdf" = browser;
      "text/html" = browser;
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "x-scheme-handler/about" = browser;
      "x-scheme-handler/unknown" = browser;
      "image/svg+xml" = browser;

      "image/bmp" = images;
      "image/gif" = images;
      "image/jpeg" = images;
      "image/jpg" = images;
      "image/pjpeg" = images;
      "image/png" = images;
      "image/tiff" = images;
      "image/heif" = images;

      "text/plain" = terminal;
      "text/markdown" = terminal;
      "text/javascript" = terminal;
      "text/vnd.trolltech.linguist" = terminal;
      "text/x-java" = terminal;
    };
  };
}
