{ pkgs, ... }: {
  environment.systemPackages = [
    (pkgs.discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
  ];

  hjem.users.javi.files = {
    ".config/Vencord/settings/settings.json".text = builtins.toJSON {
      # Nix pins the Vencord version; let it self-update and it'll just get
      # overwritten by the next rebuild anyway.
      autoUpdate = false;
      autoUpdateNotification = false;
      notifyAboutUpdates = false;

      useQuickCss = true;
      themeLinks = [ "https://capnkitten.github.io/BetterDiscord/Themes/Translucence/css/source.css" ];
      enabledThemes = [ ];

      disableMinSize = false;
      winCtrlQ = false;
      macosTranslucency = false;
      winNativeTitleBar = false;

      notifications = {
        timeout = 5000;
        position = "bottom-right";
        useNative = "not-focused";
        logLimit = 50;
      };

      cloud = {
        authenticated = false;
        url = "https://api.vencord.dev/";
        settingsSync = false;
        settingsSyncVersion = 0;
      };

      plugins = {
        # Logs edited/deleted messages instead of silently dropping them.
        iLoveSpam.enabled = true;
        AlwaysTrust.enabled = true;
        FakeNitro.enabled = true;
        MessageLogger.enabled = true;
        FixImagesQuality.enabled = true;
        FixSpotifyEmbeds.enabled = true;
        FixYoutubeEmbeds.enabled = true;
        FixCodeblockGap.enabled = true;
        ImageLink.enabled = true;
        VolumeBooster.enabled = true;
        NoProfileThemes.enabled = true;
        TypingIndicator.enabled = true;
        TypingTweaks.enabled = true;
        SilentTyping.enabled = true;
      };
    };

    ".config/Vencord/settings/quickCss.css".text = "";
  };
}
