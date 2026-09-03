{ self, inputs, ... }:
{

  flake.homeModules.locale =
    { pkgs, ... }:
    {
      i18n.glibcLocales = pkgs.glibcLocales.override {
        allLocales = false;
        locales = [
          "en_US.UTF-8/UTF-8"
          "fr_FR.UTF-8/UTF-8"
        ];
      };
    };
}
