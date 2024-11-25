{ pkgs, inputs, ... }:

{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      wakatime
      inputs.wakatime-lsp.packages."x86_64-linux".wakatime-lsp
      nil
      nixfmt-classic
      python312Packages.python-lsp-server
      clang-tools
      marksman
    ];

    settings = {
      theme = "onedark";

      editor = {
        auto-format = true;
        auto-save = true;
        mouse = false;
        bufferline = "multiple";
        file-picker.hidden = false;

        indent-guides = {
          render = true;
          characters = "╎";
        };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
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
