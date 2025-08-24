{
  imports = [
    ./dock.nix
    ./finder.nix
  ];

  programs.zsh.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    menuExtraClock.Show24Hour = true;
    menuExtraClock.ShowSeconds = false;

    controlcenter = {
      BatteryShowPercentage = false;
      Bluetooth = true;
      NowPlaying = true;
      Sound = false;
      FocusModes = false;
      Display = false;
      AirDrop = false;
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";

      AppleICUForce24HourTime = true;

      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleTemperatureUnit = "Celsius";

      NSWindowShouldDragOnGesture = true;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;

      "com.apple.keyboard.fnState" = true;
    };

    CustomSystemPreferences."com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
      allowIdentifierForAdvertising = false;
      forceLimitAdTracking = true;
      personalizedAdsMigrated = false;
    };

    CustomUserPreferences.NSGlobalDomain = {
      AppleIconAppearanceTheme = "ClearDark";
      AppleIconAppearanceTintColor = "Graphite";
      AppleLocale = "en_AE";
      AppleLanguages = [
        "en-AE"
        "ar-AE"
      ];
    };
  };
}
