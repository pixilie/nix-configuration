{ self, inputs, ... }:
{

  flake.homeModules.sh =
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

        programs.fish = {
          enable = true;
          functions.fish_greeting = "";
        };

        programs.starship = {
          enable = true;
          enableFishIntegration = true;

          settings = {
            nix_shell = {
              format = "via [$symbol$state]($style) ";
              symbol = " ";
            };

            git_branch.disabled = false;
            git_commit.disabled = false;
            git_metrics.disabled = false;
            git_state.disabled = false;
            git_status.disabled = false;
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

      (lib.mkIf (!config.isLightProfile) {
        home.packages = with pkgs; [
          eza
          bat
          fzf
          zoxide
          delta
          tlrc
          fd
        ];

        programs.fish = {
          shellAliases = {
            ls = "${lib.getExe pkgs.eza} --color=auto --icons=auto --hyperlink";
            cat = "${lib.getExe pkgs.bat}";
          };

          shellAbbrs = {
            ll = "ls -lhaF";
            tree = "ls -T";
            ghd = "gh-dash";
            findg = "find . -name .git -type d -prune";
            nixd = "nix develop -c fish";
            geany = "nohup geany . > /dev/null &";
          };

          functions.cdtmp = ''
            set ash (openssl rand -hex 4)
            mkdir /tmp/$ash
            cd /tmp/$ash
          '';
        };

        programs.zoxide = {
          enable = true;
          enableFishIntegration = true;
          options = [ "--cmd cd" ];
        };

        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
          silent = true;
        };
        home.sessionVariables.DIRENV_LOG_FORMAT = "";

        programs.bat.extraPackages = with pkgs.bat-extras; [ batman ];
      })
    ];
}
