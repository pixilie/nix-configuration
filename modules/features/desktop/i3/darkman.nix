{ self, inputs, ... }:
{

  flake.homeModules.darkmanI3 =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      lnExe = "${pkgs.coreutils}/bin/ln";
      dconfExe = "${pkgs.dconf}/bin/dconf";
      fehExe = "${pkgs.feh}/bin/feh";
      systemctlExe = "${pkgs.systemd}/bin/systemctl";

      rofiThemes = "${config.xdg.dataHome}/rofi/themes";
      polybarDir = "${config.xdg.configHome}/polybar";
    in
    {
      services.darkman = {
        enable = true;
        package = pkgs.darkman;

        settings = {
          usegeoclue = true;
        };

        darkModeScripts = {
          gtk-theme = ''
            ${dconfExe} write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
          '';

          wallpaper = ''
            ${fehExe} --bg-fill ${../../../../assets/media/wallpaper_dark.png}
          '';

          rofi = ''
            ${lnExe} -sfn ${rofiThemes}/dark.rasi ${rofiThemes}/current.rasi
          '';

          polybar-theme = ''
            ${lnExe} -sfn ${polybarDir}/colors-dark.ini ${polybarDir}/colors.ini
            ${systemctlExe} --user restart polybar.service
          '';
        };

        lightModeScripts = {
          gtk-theme = ''
            ${dconfExe} write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
          '';

          wallpaper = ''
            ${fehExe} --bg-fill ${../../../../assets/media/wallpaper_light.png}
          '';

          rofi = ''
            ${lnExe} -sfn ${rofiThemes}/light.rasi ${rofiThemes}/current.rasi
          '';

          polybar-theme = ''
            ${lnExe} -sfn ${polybarDir}/colors-light.ini ${polybarDir}/colors.ini
            ${systemctlExe} --user restart polybar.service
          '';
        };
      };

      xsession.windowManager.i3.config.startup = [
        { command = "${pkgs.geoclue2}/libexec/geoclue-2.0/demos/agent"; }
        {
          command = "systemctl --user import-environment DISPLAY XAUTHORITY && systemctl --user start hm-graphical-session.target";
          always = true;
          notification = false;
        }
      ];
    };
}
