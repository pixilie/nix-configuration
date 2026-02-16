{ pkgs, upkgs, ... }:

{
  programs.zed-editor = {
    enable = true;
    package = upkgs.zed-editor;

    extraPackages = with pkgs; [
      wakatime-cli
    ];

    userSettings = {
      base_keymap = "VSCode";
      autosave = "on_focus_change";
      restore_on_startup = "last_session";
      tab_size = 4;
      formatter = "language_server";

      buffer_font_family = "CaskaydiaCove Nerd Font";
      buffer_font_size = 16;
      buffer_font_weight = 500;

      ui_font_family = ".ZedMono";
      ui_font_size = 16;
      ui_font_weight = 500;

      terminal.shell.program = "fish";

      show_edit_predictions = false;
      features = { edit_prediction_provider = "none"; };
      show_completions_on_input = true;

      auto_install_extensions = {
        "html" = true;
        "python" = true;
        "wakatime" = true;
        "git-firefly" = true;
        "sql" = true;
        "one-dark-pro" = true;
        "csharp" = true;
        "toml" = true;
        "dockerfile" = true;
        "scss" = true;
        "log" = true;
        "html-snippets" = true;
        "nix" = true;
      };

      theme = {
        mode = "system";
        light = "One Light";
        dark = "One Dark Pro";
      };

      tabs = {
        file_icons = true;
        git_status = true;
      };

      indent_guides = {
        line_width = 1;
        active_line_width = 2;
      };
    };
  };
}
