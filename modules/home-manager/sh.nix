{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    eza
    lazygit
    tokei
    bat
    fzf
    gh-dash
    zoxide
    delta
    tlrc
  ];

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
      name = "CaskaydiaCoveNerdFont";
      size = 13;
    };

    extraConfig = ''
      disable_ligatures never
      shell fish
    '';
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
      findg = "find . -name .git -type d -prune";
    };

    functions = {
      fish_greeting = "";
      init-tp = {
        body =
          "python3 /home/kristen/developement/github.com/pixilie/nix-configuration/assets/scripts/init-tp.py $argv[1] $argv[2]";
      };
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings.nix_shell = {
      format = "via [$symbol$state]($style) ";
      symbol = " ";
    };
  };

  programs.zellij.enable = true;
  xdg.configFile."zellij/config.kdl".source = ../../assets/config/zellij.kdl;

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  home.sessionVariables.DIRENV_LOG_FORMAT = "";
}
