{config, pkgs, ...}:

{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    
    settings = {
      theme = "onedark";
      
      editor = {
        auto-format = true;
        auto-save = true;
        mouse = false;

        indent-guides = {
          render = true;
          characters = "╎";  
        };
      };
    };
   
    languages = {
      language-server = {
        wakatime.command = "wakatime-lsp";
      };
        
      language = [
        {name = "nix"; auto-format = true; language-servers = [ "nil" "wakatime" ]; }
      ];
    };
  };
}
