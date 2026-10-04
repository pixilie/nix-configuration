{ self, inputs, ... }:
{

  flake.homeModules.thunderbird =
    { config, lib, ... }:
    let
      profile = "6j069bhm.default";
      rustical = "https://rustical.pixilie.net";
      gmail = config.identity.email;
      gmailImap = "imap://${builtins.replaceStrings [ "@" ] [ "%40" ] gmail}@imap.gmail.com";
      gmailIdentity = "id_${builtins.hashString "sha256" "gmail"}";

      replySettings = id: {
        "mail.identity.id_${id}.reply_on_top" = 1;
        "mail.identity.id_${id}.sig_bottom" = true;
      };

      caldav =
        {
          color,
          path,
          settings ? _: { },
        }:
        {
          remote = {
            type = "caldav";
            url = "${rustical}/caldav/principal/kristen/${path}/";
            userName = "kristen";
          };
          thunderbird = {
            enable = true;
            inherit color settings;
          };
        };
    in
    {
      xdg.mimeApps.defaultApplications = lib.genAttrs [
        "x-scheme-handler/mailto"
        "message/rfc822"
        "text/calendar"
        "text/x-vcard"
      ] (_: [ "thunderbird.desktop" ]);

      programs.thunderbird = {
        enable = true;

        policies.ExtensionSettings."languagetool-mailextension@languagetool.org" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/grammar-and-spell-checker/latest.xpi";
        };

        settings = {
          "mail.compose.add_link_preview" = true;
          "mail.SpellCheckBeforeSend" = true;
          "mail.spellcheck.inline" = false;
          "mail.threadpane.cardsview.rowcount" = 2;
          "mailnews.start_page.url" = "";
          "mail.shell.checkDefaultClient" = false;
          "offline.download.download_messages" = 1;
          "offline.send.unsent_messages" = 1;
          "searchintegration.enable" = false;

          "calendar.agenda.days" = 7;
          "calendar.notifications.times" = "-PT30M";
          "calendar.timezone.useSystemTimezone" = true;
          "calendar.view.daystarthour" = 0;
          "calendar.view.dayendhour" = 24;
          "calendar.view.visiblehours" = 15;
          "calendar.view.showLocation" = false;
        };

        profiles.${profile} = {
          isDefault = true;
          accountsOrder = [
            "gmail"
            "epita"
            "account2"
          ];
          calendarAccountsOrder = [
            "Family"
            "Training"
            "Work"
            "Personal"
            "Birthdays"
          ];
        };
      };

      accounts.email.accounts = {
        gmail = {
          primary = true;
          flavor = "gmail.com";
          address = gmail;
          realName = config.identity.name;
          thunderbird = {
            enable = true;
            settings = id: {
              "mail.server.server_${id}.name" = gmail;
              "mail.server.server_${id}.check_new_mail" = true;
              "mail.server.server_${id}.trash_folder_name" = "[Gmail]/Bin";
              "mail.server.server_${id}.moveTargetMode" = 1;
              "mail.server.server_${id}.spamActionTargetFolder" = "${gmailImap}/[Gmail]/Spam";
            };
            perIdentitySettings =
              id:
              replySettings id
              // {
                "mail.identity.id_${id}.archive_folder" = "${gmailImap}/[Gmail]/All Mail";
                "mail.identity.id_${id}.archives_folder_picker_mode" = "1";
                "mail.identity.id_${id}.draft_folder" = "${gmailImap}/[Gmail]/Drafts";
                "mail.identity.id_${id}.drafts_folder_picker_mode" = "1";
                "mail.identity.id_${id}.fcc_folder" = "${gmailImap}/[Gmail]/Sent Mail";
                "mail.identity.id_${id}.fcc_folder_picker_mode" = "1";
              };
          };
        };

        epita = {
          flavor = "outlook.office365.com";
          address = "kristen.couty@epita.fr";
          realName = config.identity.name;
          thunderbird = {
            enable = true;
            settings = id: {
              "mail.server.server_${id}.name" = "kristen.couty@epita.fr";
              "mail.server.server_${id}.check_new_mail" = true;
              "mail.server.server_${id}.trash_folder_name" = "Trash";
            };
            perIdentitySettings = replySettings;
          };
        };
      };

      accounts.calendar.accounts = {
        Family = caldav {
          color = "#ff80ff";
          path = "73e626da-d4fe-46e7-96f6-9472a936c9a6";
        };
        Training = caldav {
          color = "#ff7800";
          path = "80677bf9-55b8-4cef-b2b4-74f137811502";
        };
        Work = caldav {
          color = "#77767b";
          path = "916446a6-aa40-4e8d-92e0-ad5d8acb3c6c";
          settings = id: {
            "calendar.registry.calendar_${id}.refreshInterval" = "30";
            "calendar.registry.calendar_${id}.notifications.times" = "";
            "calendar.registry.calendar_${id}.imip.identity.key" = gmailIdentity;
          };
        };
        Personal = caldav {
          color = "#3584e4";
          path = "bcd0cc05-4d8c-4946-bce4-ba34ef7da0e4";
        };
        Birthdays = caldav {
          color = "#33d17a";
          path = "_birthdays_9564ef12-3fb9-4911-9727-3e2d0a87c738";
        };
      };

      accounts.contact.accounts.Contacts = {
        remote = {
          type = "carddav";
          url = "${rustical}/carddav/principal/kristen/9564ef12-3fb9-4911-9727-3e2d0a87c738/";
          userName = "kristen";
        };
        thunderbird.enable = true;
      };
    };
}
