{ config, pkgs, ...  }:

{
 programs.kitty = {
    enable = true;

    settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = "no";
        macos_option_as_alt = "left";
    };
       
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
