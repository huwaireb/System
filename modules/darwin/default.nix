{
  imports = [
    ./dock.nix
    ./finder.nix
  ];

  programs.zsh.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;

  nix.linux-builder = {
    ephemeral = true;
    systems = [ "aarch64-linux" ];
    supportedFeatures = [
      "benchmark"
      "kvm"
      "big-parallel"
      "nixos-test"
    ];

    config.virtualisation = {
      cores = 8;
      darwin-builder.diskSize = 100 * 1024;
      darwin-builder.memorySize = 8 * 1024;
    };
  };

  launchd.daemons.linux-builder = {
    serviceConfig = {
      StandardOutPath = "/var/log/darwin-builder.log";
      StandardErrorPath = "/var/log/darwin-builder.log";
    };
  };

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
