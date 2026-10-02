{ self, inputs, ... }:
{

  flake.homeModules.firefox =
    { config, upkgs, ... }:
    let
      amo = slug: {
        installation_mode = "normal_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
      };

      bitwarden = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
    in
    {
      programs.firefox = {
        enable = true;
        package = upkgs.firefox;
        configPath = ".mozilla/firefox";
        languagePacks = [ "en-GB" ];

        policies = {
          ExtensionSettings = {
            ${bitwarden} = amo "bitwarden-password-manager";
            "addon@darkreader.org" = amo "darkreader";
            "jid1-NIfFY2CA8fy1tg@jetpack" = amo "adblock-for-firefox";
            "{74145f27-f039-47ce-a470-a662b129930a}" = amo "clearurls";
            "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = amo "refined-github-";
            "tab-stash@condordes.net" = amo "tab-stash";
            "extension@tabliss.io" = amo "tabliss";
            "{a8cf72f7-09b7-4cd4-9aaa-7a023bf09916}" = amo "besttimetracker";
            "marcoagpinto@mail.telepac.pt" = amo "british-english-dictionary-2";
          };
        };

        profiles.kristen = {
          id = 0;
          path = "i9g8yvrf.default";
          isDefault = true;

          search = {
            force = true;
            default = "ddg";
            privateDefault = "ddg";
          };

          settings = {
            "intl.locale.requested" = "en-GB,en-US";

            "browser.startup.page" = 3;
            "browser.tabs.warnOnClose" = true;
            "browser.ctrlTab.sortByRecentlyUsed" = true;
            "general.autoScroll" = true;
            "browser.download.dir" = "${config.home.homeDirectory}/Downloads";
            "browser.translations.automaticallyPopup" = false;
            "media.eme.enabled" = true;

            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.bookmarks.showMobileBookmarks" = false;
            "browser.toolbars.bookmarks.showOtherBookmarks" = false;

            "sidebar.revamp" = true;
            "sidebar.verticalTabs" = true;
            "sidebar.main.tools" = bitwarden;

            "signon.rememberSignons" = false;
            "browser.ipProtection.enabled" = true;

            "browser.contentblocking.category" = "strict";
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;
            "privacy.trackingprotection.emailtracking.enabled" = true;
            "privacy.trackingprotection.allow_list.convenience.enabled" = false;
            "privacy.trackingprotection.consentmanager.skip.pbmode.enabled" = false;
            "privacy.fingerprintingProtection" = true;
            "privacy.annotate_channels.strict_list.enabled" = true;
            "privacy.query_stripping.enabled" = true;
            "privacy.query_stripping.enabled.pbmode" = true;
            "privacy.bounceTrackingProtection.mode" = 1;
            "network.http.referer.disallowCrossSiteRelaxingDefault.top_navigation" = true;
            "privacy.donottrackheader.enabled" = true;
            "privacy.globalprivacycontrol.enabled" = true;
            "privacy.clearOnShutdown_v2.formdata" = true;

            "browser.uiCustomization.state" = {
              currentVersion = 26;
              newElementCount = 2;
              dirtyAreaCache = [
                "nav-bar"
                "vertical-tabs"
                "PersonalToolbar"
                "toolbar-menubar"
                "TabsToolbar"
                "unified-extensions-area"
              ];
              placements = {
                PersonalToolbar = [ "personal-bookmarks" ];
                TabsToolbar = [ ];
                nav-bar = [
                  "sidebar-button"
                  "back-button"
                  "forward-button"
                  "stop-reload-button"
                  "vertical-spacer"
                  "customizableui-special-spring1"
                  "urlbar-container"
                  "customizableui-special-spring2"
                  "downloads-button"
                  "ipprotection-button"
                  "fxa-toolbar-menu-button"
                  "unified-extensions-button"
                  "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
                  "alltabs-button"
                  "reset-pbm-toolbar-button"
                  "smartwindow-group-tabs-button"
                  "ai-window-toggle"
                ];
                toolbar-menubar = [ "menubar-items" ];
                unified-extensions-area = [
                  "jid1-niffy2ca8fy1tg_jetpack-browser-action"
                  "tab-stash_condordes_net-browser-action"
                  "addon_darkreader_org-browser-action"
                  "_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action"
                  "_74145f27-f039-47ce-a470-a662b129930a_-browser-action"
                  "_a8cf72f7-09b7-4cd4-9aaa-7a023bf09916_-browser-action"
                ];
                vertical-tabs = [ "tabbrowser-tabs" ];
                widget-overflow-fixed-list = [ ];
              };
              seen = [
                "save-to-pocket-button"
                "developer-button"
                "screenshot-button"
                "ipprotection-button"
                "reset-pbm-toolbar-button"
                "smartwindow-group-tabs-button"
                "ai-window-toggle"
                "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
                "jid1-niffy2ca8fy1tg_jetpack-browser-action"
                "tab-stash_condordes_net-browser-action"
                "addon_darkreader_org-browser-action"
                "_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action"
                "_74145f27-f039-47ce-a470-a662b129930a_-browser-action"
                "_a8cf72f7-09b7-4cd4-9aaa-7a023bf09916_-browser-action"
              ];
            };
          };
        };
      };
    };
}
