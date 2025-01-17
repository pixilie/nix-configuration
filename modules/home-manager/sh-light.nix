{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [ eza bat fzf gh-dash zoxide delta tlrc ];

  programs.alacritty = {
    enable = true;

    settings = {
      window = { decorations = "buttonless"; };

      font = {
        size = 13.0;
        normal.family = "CaskaydiaCoveNerdFont";
        bold.family = "CaskaydiaCoveNerdFont";
        italic.family = "CaskaydiaCoveNerdFont";
      };

      cursor.style = "Beam";

      terminal.shell = { program = "fish"; };

      colors = {
        # Default colors
        primary = {
          background = "#000000";
          foreground = "#fffaf3";
        };

        # Normal colors
        normal = {
          black = "#222222";
          red = "#ff000f";
          green = "#8ce00a";
          yellow = "#ffb900";
          blue = "#008df8";
          magenta = "#6c43a5";
          cyan = "#00d7eb";
          white = "#ffffff";
        };

        # Bright colors
        bright = {
          black = "#444444";
          red = "#ff273f";
          green = "#abe05a";
          yellow = "#ffd141";
          blue = "#0092ff";
          magenta = "#6c43a5";
          cyan = "#67ffef";
          white = "#ffffff";
        };
      };
    };
  };

  programs.fish = {
    enable = true;

    shellAliases = {
      ls = "${lib.getExe pkgs.eza} --color=auto --icons=auto --hyperlink";
      cat = "${lib.getExe pkgs.bat}";
    };

    shellAbbrs = {
      ll = "ls -lhaF";
      tree = "ls -T";

      ghd = "gh-dash";
    };

    functions = { fish_greeting = ""; };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings.nix_shell = {
      format = "via [$symbol$state]($style) ";
      symbol = " ";
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd cd" ];
  };
}
