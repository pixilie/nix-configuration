{ upkgs, ... }:

{
  programs.zed-editor = {
    enable = true;
    package = upkgs.zed-editor;

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
        enable = true;
        line_width = 1;
        active_line_width = 2;
      };
    };
  };
}
