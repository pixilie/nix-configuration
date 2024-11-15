{ ... }:

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
        rust-analyzer.config = { check.command = "clippy"; };
      };

      language = [
        {
          name = "nix";
          auto-format = true;
          formatter = { command = "nixfmt"; };
          language-servers = [ "nil" "wakatime" ];
        }
        {
          name = "python";
          auto-format = true;
          language-servers = [ "pylsp" "wakatime" ];
        }
        {
          name = "rust";
          auto-format = true;
          language-servers = [ "rust-analyzer" "wakatime" ];
        }
      ];
    };
  };
}
