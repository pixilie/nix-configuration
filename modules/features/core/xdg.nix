{ self, inputs, ... }:
{

  flake.homeModules.xdg =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      files = [ "org.gnome.Nautilus.desktop" ];
      browser = [ "firefox.desktop" ];
      images = [ "com.github.weclaw1.ImageRoll.desktop" ];
      editor = [ "helix.desktop" ];

      editorMimes = [
        "text/plain"
        "text/markdown"
        "text/javascript"
        "text/vnd.trolltech.linguist"
        "text/x-java"
      ];
    in
    {
      xdg.desktopEntries.helix = {
        name = "Helix";
        genericName = "Text Editor";
        exec = "${lib.getExe pkgs.alacritty} -e ${config.programs.helix.package}/bin/hx %F";
        icon = "text-editor";
        terminal = false;
        categories = [
          "Utility"
          "TextEditor"
        ];
        mimeType = editorMimes;
      };

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
        }
        // lib.genAttrs editorMimes (_: editor);
      };
    };
}
