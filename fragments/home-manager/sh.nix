{ config, pkgs, ...  }:

{
 programs.kitty = {
    enable = true;
       
    shellIntegration = {
      mode = "enabled";
      enableFishIntegration = true;
    };
        
    font = {
      name = "JetBrainsMono";
      size = 12;
    };

    extraConfig = ''
      shell fish
    '';
  };

  programs.fish = {
    enable = true;

    shellInit = '' #TODO: Disable greeting
    '';
    
    shellAliases = {
      ".." = "cd ..";
        ll = "ls -l";
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };
}
