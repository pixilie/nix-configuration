{ self, inputs, ... }:
{

  flake.homeModules.alacrittySchool = {
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

        colors = {
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
      };
    };
  };
}
