{ self, inputs, ... }:
{

  flake.homeModules.helixSchool =
    { pkgs, config, ... }:
    {
      programs.helix = {
        enable = true;

        package =
          if config.useHelixCache then
            pkgs.helix
          else
            inputs.helix-editor.packages.${pkgs.stdenv.hostPlatform.system}.helix;

        defaultEditor = false;

        extraPackages = [
          pkgs.asm-lsp
          pkgs.wakatime-cli
          inputs.wakatime-ls.packages.${pkgs.stdenv.hostPlatform.system}.wakatime-ls
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
            auto-format = false;
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
          language-server.wakatime.command = "wakatime-ls";

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
              name = "make";
              auto-format = false;
              language-servers = [ "wakatime" ];
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
