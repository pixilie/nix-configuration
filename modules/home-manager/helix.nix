{ pkgs, inputs, ... }:

{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      # Wakatime related
      wakatime
      inputs.wakatime-lsp.packages."x86_64-linux".wakatime-lsp

      # Nix Related
      nil
      nixfmt-classic

      # C related
      clang-tools

      # markdown
      marksman

      # Python related
      ruff
      ruff-lsp
      python312Packages.jedi

      # Ocaml related
      ocamlPackages.ocaml-lsp
      ocamlPackages.utop
      ocamlPackages.ocamlformat

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
        ruff.command = "ruff-lsp";
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
          language-servers = [ "ruff" "jedi" "wakatime" ];
        }
        {
          name = "rust";
          auto-format = true;
          language-servers = [ "rust-analyzer" "wakatime" ];
        }
        {
          name = "markdown";
          language-servers = [ "marksman" "wakatime" ];
        }
        {
          name = "ocaml";
          auto-format = true;
          language-servers = [ "ocamllsp" "wakatime" ];
        }
      ];
    };
  };
}
