{ upkgs, ... }:

{
  programs.zed-editor = {
    enable = true;
    package = upkgs.zed-editor;
    userSettings = {
      base_keymap = "VSCode";
      autosave = "on_focus_change";

      restore_on_startup = "last_session";

      ui_font_size = 16;
      ui_font_family = ".SystemUIFont";
      ui_font_weight = 500;
      buffer_font_family = ".SystemUIFont";
      buffer_font_size = 16;
      buffer_font_weight = 500;
      tab_size = 4;

      theme = {
        mode = "dark";
        light = "One Light";
        dark = "One Dark Pro";
      };

      tabs = {
        file_icons = true;
        git_status = true;
      };

      formatter = "language_server";

      indent_guides = {
        enable = true;
        line_width = 1;
        active_line_width = 2;
      };
    };
  };
}
