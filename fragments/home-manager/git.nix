{config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Kristen Couty";
    userEmail = "kristen.couty@gmail.com";
  };

  programs.gh.enable = true;
  
}
