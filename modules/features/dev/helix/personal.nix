{ self, inputs, ... }:
{

  flake.homeModules.helixPersonal =
    { pkgs, config, ... }:
    {
      programs.helix = {
        enable = true;

        package =
          if config.useHelixCache then
            inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.helix
          else
            inputs.helix-editor.packages.${pkgs.stdenv.hostPlatform.system}.helix;

        defaultEditor = true;

        extraPackages = with pkgs; [
          asm-lsp
          wakatime-cli
          inputs.wakatime-ls.packages.${pkgs.stdenv.hostPlatform.system}.wakatime-ls
          bash-language-server
          clang-tools
          lldb_21
          nil
          nixfmt
          pyright
          ruff
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
          theme = "current";
          editor = {
            auto-format = true;
            auto-save = true;
            mouse = false;
            bufferline = "multiple";
            cursorline = true;
            color-modes = true;
            undercurl = true;
            popup-border = "all";

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

            lsp = {
              display-inlay-hints = true;
              display-progress-messages = true;
            };
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
            rust-analyzer.config = {
              check.command = "clippy";
            };
            pyright = {
              command = "pyright-langserver";
              args = [ "--stdio" ];
            };
            ruff = {
              command = "ruff";
              args = [ "server" ];
            };
          };

          language = [
            {
              name = "gas";
              auto-format = false;
              file-types = [ "S" ];
              language-servers = [
                {
                  name = "asm-lsp";
                  except-features = [
                    "completion"
                    "diagnostics"
                    "signature-help"
                  ];
                }
                "wakatime"
              ];
            }
            {
              name = "nasm";
              file-types = [
                "asm"
                "nasm"
              ];
            }
            {
              name = "c";
              auto-format = false;
              language-servers = [
                "clangd"
                "wakatime"
              ];
              formatter = {
                command = "clang-format";
              };
            }
            {
              name = "bash";
              auto-format = false;
              language-servers = [
                "bash-language-server"
                "wakatime"
              ];
            }
            {
              name = "python";
              auto-format = false;
              language-servers = [
                "pyright"
                "ruff"
                "wakatime"
              ];
            }
            {
              name = "nix";
              formatter = {
                command = "nixfmt";
              };
              language-servers = [
                "nil"
                "wakatime"
              ];
            }
            {
              name = "rust";
              auto-format = false;
              language-servers = [
                "rust-analyzer"
                "wakatime"
              ];
            }
          ];
        };
      };

      xdg.configFile."asm-lsp/.asm-lsp.toml".source = (pkgs.formats.toml { }).generate "asm-lsp.toml" {
        default_config = {
          assembler = "gas";
          instruction_set = "x86-64";
          opts = {
            diagnostics = false;
            default_diagnostics = false;
          };
        };
      };
    };
}
