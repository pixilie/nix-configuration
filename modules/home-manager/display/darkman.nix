{ pkgs, config, ... }:

let pkillExe = "${pkgs.procps}/bin/pkill";
in {
  services.darkman = {
    enable = true;
    package = pkgs.darkman;

    settings = { usegeoclue = true; };

    darkModeScripts = {
      gtk-theme = ''
        ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
      '';

      wallpaper = ''
        ${pkgs.sway}/bin/swaymsg output "*" bg ${
          ../../../assets/media/wallpaper_dark.png
        } fill
      '';

      mako = ''
        ${pkgs.mako}/bin/makoctl mode -r light
      '';

      rofi = ''
        ln -sf ${config.xdg.dataHome}/rofi/themes/dark.rasi ${config.xdg.dataHome}/rofi/themes/current.rasi
      '';

      waybar-theme = ''
        ln -sf ${config.xdg.configHome}/waybar/colors-dark.css ${config.xdg.configHome}/waybar/colors.css
        ${pkillExe} -SIGUSR2 waybar
      '';
    };

    lightModeScripts = {
      gtk-theme = ''
        ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
      '';

      wallpaper = ''
        ${pkgs.sway}/bin/swaymsg output "*" bg ${
          ../../../assets/media/wallpaper_light.png
        } fill
      '';

      mako = ''
        ${pkgs.mako}/bin/makoctl mode -a light
      '';

      rofi = ''
        ln -sf ${config.xdg.dataHome}/rofi/themes/light.rasi ${config.xdg.dataHome}/rofi/themes/current.rasi
      '';

      waybar-theme = ''
        ln -sf ${config.xdg.configHome}/waybar/colors-light.css ${config.xdg.configHome}/waybar/colors.css
        ${pkillExe} -SIGUSR2 waybar
      '';
    };
  };
}
