{ self, inputs, ... }:
{

  flake.homeModules.shSchool = {
    programs.fish = {
      enable = true;
      functions.fish_greeting = "";
      generateCompletions = false;
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
