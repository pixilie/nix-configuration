{ self, inputs, ... }:
{

  flake.homeModules.alacritty =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      tomlFormat = pkgs.formats.toml { };

      darkColors = {
        primary = {
          background = "#000000";
          foreground = "#fffaf3";
        };

        normal = {
          black = "#222222";
          red = "#ff000f";
          green = "#9bff00";
          yellow = "#ffb900";
          blue = "#0091ff";
          magenta = "#ff00ff";
          cyan = "#00e9ff";
          white = "#ffffff";
        };

        bright = {
          black = "#444444";
          red = "#ff4d60";
          green = "#b8ff4d";
          yellow = "#ffd44d";
          blue = "#4db3ff";
          magenta = "#ff4dff";
          cyan = "#67ffef";
          white = "#ffffff";
        };
      };

      lightColors = {
        primary = {
          background = "#fafafa";
          foreground = "#383a42";
        };

        normal = {
          black = "#383a42";
          red = "#e45649";
          green = "#50a14f";
          yellow = "#c18401";
          blue = "#4078f2";
          magenta = "#a626a4";
          cyan = "#0184bc";
          white = "#fafafa";
        };

        bright = {
          black = "#4f525e";
          red = "#e06c75";
          green = "#98c379";
          yellow = "#e5c07b";
          blue = "#61afef";
          magenta = "#c678dd";
          cyan = "#56b6c2";
          white = "#ffffff";
        };
      };
    in
    lib.mkMerge [
      {
        programs.alacritty = {
          enable = true;

          settings = {
            terminal.shell = {
              program = "fish";
            };

            window = {
              decorations = "None";
            };

            font = {
              size = 14.0;
              normal.family = "CaskaydiaCoveNerdFont";
              bold.family = "CaskaydiaCoveNerdFont";
              italic.family = "CaskaydiaCoveNerdFont";
            };

            cursor = {
              style = {
                shape = "Beam";
                blinking = "Always";
              };
            };
          };
        };
      }

      (lib.mkIf config.isSchoolProfile {
        programs.alacritty.settings.colors = darkColors;
      })

      (lib.mkIf (!config.isSchoolProfile) {
        programs.alacritty.settings.general.import = [
          "${config.xdg.configHome}/alacritty/colors.toml"
        ];

        xdg.configFile = {
          "alacritty/colors-dark.toml".source = tomlFormat.generate "alacritty-colors-dark" {
            colors = darkColors;
          };
          "alacritty/colors-light.toml".source = tomlFormat.generate "alacritty-colors-light" {
            colors = lightColors;
          };
        };
      })
    ];
}
