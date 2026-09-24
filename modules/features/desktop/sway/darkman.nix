{ self, inputs, ... }: {

  flake.homeModules.darkmanSway =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      pkillExe = "${pkgs.procps}/bin/pkill";
      lnExe = "${pkgs.coreutils}/bin/ln";
      catExe = "${pkgs.coreutils}/bin/cat";
      alacrittyColors = "${config.xdg.configHome}/alacritty";
      helixThemes = "${config.xdg.configHome}/helix/themes";
      mkdirExe = "${pkgs.coreutils}/bin/mkdir";
      echoExe = "${pkgs.coreutils}/bin/echo";
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
            ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
          '';

          wallpaper = ''
            # Ajustez le nombre de ../ si nécessaire selon l'emplacement du fichier
            ${pkgs.sway}/bin/swaymsg output "*" bg ${../../../../assets/media/wallpaper_dark.png} fill
          '';

          mako = ''
            ${pkgs.mako}/bin/makoctl mode -r light
          '';

          rofi = ''
            ${lnExe} -sf ${config.xdg.dataHome}/rofi/themes/dark.rasi ${config.xdg.dataHome}/rofi/themes/current.rasi
          '';

          waybar-theme = ''
            ${lnExe} -sf ${config.xdg.configHome}/waybar/colors-dark.css ${config.xdg.configHome}/waybar/colors.css
            ${pkillExe} -x -SIGUSR2 waybar
          '';

          alacritty = ''
            ${catExe} ${alacrittyColors}/colors-dark.toml > ${alacrittyColors}/colors.toml
          '';

          helix = ''
            ${mkdirExe} -p ${helixThemes}
            ${echoExe} 'inherits = "onedark"' > ${helixThemes}/current.toml
            ${pkillExe} -USR1 -x hx || true
            ${pkillExe} -USR1 -x .hx-wrapped_ || true
          '';
        };

        lightModeScripts = {
          gtk-theme = ''
            ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
          '';

          wallpaper = ''
            ${pkgs.sway}/bin/swaymsg output "*" bg ${../../../../assets/media/wallpaper_light.png} fill
          '';

          mako = ''
            ${pkgs.mako}/bin/makoctl mode -a light
          '';

          rofi = ''
            ${lnExe} -sf ${config.xdg.dataHome}/rofi/themes/light.rasi ${config.xdg.dataHome}/rofi/themes/current.rasi
          '';

          waybar-theme = ''
            ${lnExe} -sf ${config.xdg.configHome}/waybar/colors-light.css ${config.xdg.configHome}/waybar/colors.css
            ${pkillExe} -x -SIGUSR2 waybar
          '';

          alacritty = ''
            ${catExe} ${alacrittyColors}/colors-light.toml > ${alacrittyColors}/colors.toml
          '';

          helix = ''
            ${mkdirExe} -p ${helixThemes}
            ${echoExe} 'inherits = "onelight"' > ${helixThemes}/current.toml
            ${pkillExe} -USR1 -x hx || true
            ${pkillExe} -USR1 -x .hx-wrapped_ || true
          '';
        };
      };
    };
}
