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
      swayncClientExe = "${config.services.swaync.package}/bin/swaync-client";
      swayncColors = "${config.xdg.configHome}/swaync";

      qtTheme = mode: scheme: ''
        place() {
          ${pkgs.coreutils}/bin/install -m 644 "$1" "$2.tmp"
          ${pkgs.coreutils}/bin/mv -f "$2.tmp" "$2"
        }
        for qtct in qt5ct qt6ct; do
          place ${config.xdg.configHome}/$qtct/colors/${mode}.conf ${config.xdg.configHome}/$qtct/colors.conf
        done
        place ${config.xdg.dataHome}/color-schemes/${scheme}.colors ${config.xdg.configHome}/kdeglobals
        ${pkgs.systemd}/bin/busctl --user emit /kdeglobals org.kde.kconfig.notify ConfigChanged "a{saay}" 1 Colors:Header 0 || true
      '';
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

          qt-theme = qtTheme "dark" "OneDark";

          wallpaper = ''
            ${pkgs.sway}/bin/swaymsg output "*" bg ${../../../../assets/media/wallpaper_dark.png} fill
          '';

          swaync = ''
            ${lnExe} -sf ${swayncColors}/colors-dark.css ${swayncColors}/colors.css
            ${swayncClientExe} --reload-css --skip-wait || true
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

          qt-theme = qtTheme "light" "OneLight";

          wallpaper = ''
            ${pkgs.sway}/bin/swaymsg output "*" bg ${../../../../assets/media/wallpaper_light.png} fill
          '';

          swaync = ''
            ${lnExe} -sf ${swayncColors}/colors-light.css ${swayncColors}/colors.css
            ${swayncClientExe} --reload-css --skip-wait || true
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
