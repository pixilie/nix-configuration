{ self, inputs, ... }:
{

  flake.homeModules.shSchool = {
    programs.fish = {
      enable = true;
      functions.fish_greeting = "";
      generateCompletions = false;

      shellAbbrs = {
        cp = "cp -v";
        mv = "mv -v";
        rm = "rm -v -i";
        ln = "ln -v";
        mkdir = "mkdir -v";
        rmdir = "rmdir -v";
        chmod = "chmod -v";
        chown = "chown -v";
      };
    };

    programs.man.generateCaches = false;

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
  };
}
