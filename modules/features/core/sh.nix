{ self, inputs, ... }: {

  flake.homeModules.sh =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    lib.mkMerge [
      {
        programs.alacritty = {
          enable = true;
          settings.terminal.shell = {
            program = "fish";
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

        programs.alacritty.settings = {
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
              magenta = "#FF00FF";
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
