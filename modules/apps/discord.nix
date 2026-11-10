{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.discord
    # (pkgs.discord.override {
    #   withOpenASAR = false;
    #   withVencord = false;
    # })
  ];

  hjem.users.javi.files = {
    ".config/Vencord/settings/settings.json".text = builtins.toJSON {
      # Nix pins the Vencord version; let it self-update and it'll just get
      # overwritten by the next rebuild anyway.
      autoUpdate = true;
      autoUpdateNotification = false;
      notifyAboutUpdates = false;

      useQuickCss = false;
      themeLinks = [ "" ];
      # https://capnkitten.github.io/BetterDiscord/Themes/Translucence/css/source.css
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

      # Temporarily disabled while debugging Discord - flip back to true to restore.
      plugins = {
        # Logs edited/deleted messages instead of silently dropping them.
        iLoveSpam.enabled = false;
        AlwaysTrust.enabled = false;
        FakeNitro.enabled = false;
        MessageLogger.enabled = false;
        FixImagesQuality.enabled = false;
        FixSpotifyEmbeds.enabled = false;
        FixYoutubeEmbeds.enabled = false;
        FixCodeblockGap.enabled = false;
        ImageLink.enabled = false;
        VolumeBooster.enabled = false;
        NoProfileThemes.enabled = false;
        TypingIndicator.enabled = false;
        TypingTweaks.enabled = false;
        SilentTyping.enabled = false;
      };
    };

    ".config/Vencord/settings/quickCss.css".text = "";
  };
}
