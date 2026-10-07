{ self, inputs, ... }:
{

  flake.homeModules.vicinae =
    { config, lib, ... }:
    {
      programs.vicinae = {
        enable = true;
        systemd.enable = true;

        themes = {
          desktop-dark = {
            meta = {
              version = 1;
              name = "Desktop Dark";
              description = "One Dark, matching waybar, mako and rofi";
              variant = "dark";
              inherits = "vicinae-dark";
            };

            colors = {
              core = {
                background = "#1E2127";
                foreground = "#ABB2BF";
                secondary_background = "#282B31";
                border = "#353B45";
                accent = "#61AFEF";
              };
              accents = {
                blue = "#61AFEF";
                green = "#98C379";
                magenta = "#C678DD";
                orange = "#D19A66";
                purple = "#C678DD";
                red = "#E06C75";
                yellow = "#E5C07B";
                cyan = "#56B6C2";
              };
              list.item.selection = {
                background = "#353B45";
                secondary_background = "#3E4451";
              };
              grid.item.background = "#282B31";
            };
          };

          desktop-light = {
            meta = {
              version = 1;
              name = "Desktop Light";
              description = "One Light, matching waybar, mako and alacritty";
              variant = "light";
              inherits = "vicinae-light";
            };

            colors = {
              core = {
                background = "#FAFAFA";
                foreground = "#383A42";
                secondary_background = "#F0F0F1";
                border = "#E5E5E6";
                accent = "#4078F2";
              };
              accents = {
                blue = "#4078F2";
                green = "#50A14F";
                magenta = "#A626A4";
                orange = "#986801";
                purple = "#A626A4";
                red = "#E45649";
                yellow = "#C18401";
                cyan = "#0184BC";
              };
              list.item.selection = {
                background = "#E5E5E6";
                secondary_background = "#DBDBDC";
              };
              grid.item.background = "#F0F0F1";
            };
          };
        };

        settings = {
          telemetry.system_info = false;
          search_files_in_root = true;
          pop_to_root_on_close = true;
          escape_key_behavior = "close_window";

          theme = {
            dark = {
              name = "desktop-dark";
              icon_theme = config.gtk.iconTheme.name;
            };
            light = {
              name = "desktop-light";
              icon_theme = config.gtk.iconTheme.name;
            };
          };

          font.normal.size = 12.25;

          launcher_window.size = {
            width = 900;
            height = 560;
          };

          launcher_window.layer_shell = {
            enabled = true;
            keyboard_interactivity = "exclusive";
            layer = "top";
          };

          favorites = [
            "clipboard:history"
            "files:search"
          ];

          fallbacks = [ "files:search" ];
        };
      };

      wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
        "Mod4+d" = "exec vicinae toggle";
        "Mod4+Shift+d" = "exec vicinae cmd launch files:search";
      };
    };
}
