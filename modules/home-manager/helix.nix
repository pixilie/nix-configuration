{ pkgs, inputs, config, ... }:

{
  programs.helix = {
    enable = true;

    package = if config.useCache then
      pkgs.helix
    else
      inputs.helix-editor.packages."x86_64-linux".helix;

    defaultEditor = true;

    extraPackages = with pkgs; [
      # Global lsp
      wakatime
      inputs.wakatime-ls.packages."x86_64-linux".wakatime-ls

      # Nix Related
      nil
      nixfmt-classic

      # Markdown
      marksman

      # C related
      clang-tools

      # Web related
      vscode-langservers-extracted
      typescript-language-server

      # Python
      ruff
      python312Packages.jedi-language-server
      python312Packages.python-lsp-server
    ];

    settings = {
      theme = "onedark";

      editor = {
        auto-format = true;
        auto-save = true;
        mouse = false;
        bufferline = "multiple";
        file-picker.hidden = false;

        end-of-line-diagnostics = if !config.useCache then "hint" else null;
        inline-diagnostics = if !config.useCache then {
          cursor-line = "hint";
          other-lines = "error";
        } else
          null;

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

      keys = {
        normal = {
          up = "no_op";
          down = "no_op";
          left = "no_op";
          right = "no_op";

          "space" = {
            f = "file_picker_in_current_directory";
            F = "file_picker";
          };
        };
      };
    };

    languages = {
      language-server = {
        wakatime.command = "wakatime-ls";
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
          auto-format = false;
          language-servers = [ "ruff" "jedi" "pylsp" ];
        }
        {
          name = "rust";
          auto-format = true;
          language-servers = [ "rust-analyzer" "wakatime" ];
        }
        {
          name = "markdown";
          language-servers = [ "marksman" ];
        }
        {
          name = "ocaml";
          auto-format = true;
          language-servers = [ "ocamllsp" "wakatime" ];
        }
        {
          name = "javascript";
          auto-format = true;
          language-servers = [
            "typescript-language-server"
            "vscode-eslint-language-server"
            "wakatime"
          ];
        }
        {
          name = "c";
          language-servers = [ "clangd" "wakatime" ];
          auto-format = false;
          formatter = { command = "clang-format"; };
        }
        {
          name = "html";
          auto-format = true;
          language-servers = [ "vscode-html-language-server" "wakatime" ];
        }
        {
          name = "css";
          auto-format = true;
          language-servers = [ "vscode-css-language-server" "wakatime" ];
        }
      ];
    };
  };
}
