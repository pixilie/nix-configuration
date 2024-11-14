{ pkgs, config, ... }:

{
  services.mako = {
    enable = true;
    
    sort = "-time";
    maxVisible = 3;
    defaultTimeout = 5000;
        
    backgroundColor = "#17191e";
    textColor = "#ABB2BF";
    height = 100;
    width = 300;
    borderRadius = 12;
    borderSize = 0;
    maxIconSize = 55;
    padding = "10";

    extraConfig = ''
      [urgency=high]
      border-color=#E06C75
      default-timeout=0
    '';
  };
}
