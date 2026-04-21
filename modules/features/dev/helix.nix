{ self, inputs, ... }: {

  flake.homeModules.helix = { pkgs, config, lib, ... }: {
    programs.helix = {
      enable = true;

      package = if config.useHelixCache then
        pkgs.helix
      else
        inputs.helix-editor.packages.${pkgs.stdenv.hostPlatform.system}.helix;

      defaultEditor = true;

      extraPackages = with pkgs;
        [
          wakatime-cli
          inputs.wakatime-ls.packages.${pkgs.stdenv.hostPlatform.system}.wakatime-ls
          clang-tools
          lldb_21
        ] ++ lib.optionals (!config.isSchoolProfile) [
          ruff
          pyright
          marksman
          vscode-langservers-extracted
          typescript-language-server
          nil
          nixfmt-classic
        ];

      ignores = [
        "*.png"
        "*.properties"
        "*.gif"
        "*.mcmeta"
        "*.eot"
        "*.webp"
        "*.ttf"
        "*.woff"
        "*.jpg"
      ];

      settings = {
        theme = "onedark";
        editor = {
          auto-format = true;
          auto-save = true;
          mouse = false;
          bufferline = "multiple";

          end-of-line-diagnostics = "hint";
          inline-diagnostics = {
            cursor-line = "hint";
            other-lines = "error";
          };

          indent-guides = {
            render = true;
            characters = "╎";
          };

          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          lsp = { display-inlay-hints = true; };
        };

        keys = {
          normal = {
            up = "no_op";
            down = "no_op";
            left = "no_op";
            right = "no_op";
            A-u = ":toggle lsp.display-inlay-hints";

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
          pyright = {
            command = "pyright-langserver";
            args = [ "--stdio" ];
          };
          ruff = {
            command = "ruff";
            args = [ "server" ];
          };
        };

        language = [{
          name = "c";
          auto-format = false;
          language-servers = [ "clangd" "wakatime" "lldb" ];
          formatter = { command = "clang-format"; };
        }] ++ lib.optionals (!config.isSchoolProfile) [
          {
            name = "python";
            auto-format = false;
            language-servers = [ "pyright" "ruff" "wakatime" ];
          }
          {
            name = "nix";
            formatter = { command = "nixfmt"; };
            language-servers = [ "nil" "wakatime" ];
          }
          {
            name = "rust";
            auto-format = false;
            language-servers = [ "rust-analyzer" "wakatime" ];
          }
          {
            name = "markdown";
            language-servers = [ "marksman" ];
          }
          {
            name = "javascript";
            auto-format = false;
            language-servers = [
              "typescript-language-server"
              "vscode-eslint-language-server"
              "wakatime"
            ];
          }
          {
            name = "typescript";
            auto-format = false;
            language-servers = [
              "typescript-language-server"
              "vscode-eslint-language-server"
              "wakatime"
            ];
          }
          {
            name = "html";
            auto-format = false;
            language-servers = [ "vscode-html-language-server" "wakatime" ];
          }
          {
            name = "css";
            auto-format = false;
            language-servers = [ "vscode-css-language-server" "wakatime" ];
          }
          {
            name = "json";
            auto-format = false;
            language-servers = [ "vscode-json-language-server" ];
          }
          {
            name = "cpp";
            auto-format = false;
            language-servers = [ "clangd" "wakatime" "lldb" ];
            formatter = { command = "clang-format"; };
          }
        ];
      };
    };
  };
}
