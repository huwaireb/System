{
  inputs,
  config,
  pkgs,
  ...
}:
let
  is-desktop = config.type == "desktop";

  locked = attrs: attrs // { Locked = true; };
  lockedAs = Value: attrs: (locked attrs) // { inherit Value; };

  install = url: {
    install_url = url;
    installation_mode = "force_installed";
  };
  installPublished =
    ext: install "https://addons.mozilla.org/firefox/downloads/latest/${ext}/latest.xpi";

  policies = {
    AutofillAddressEnabled = true;
    AutofillCreditCardEnabled = false;

    DisableAppUpdate = true;
    AppAutoUpdate = false;
    BackgroundAppUpdate = false;

    DisablePocket = true;
    DisableTelemetry = true;
    DisableProfileImport = true;
    DisableProfileRefresh = true;
    DisableFeedbackCommands = true;
    DisableFirefoxStudies = true;

    DontCheckDefaultBrowser = true;
    NoDefaultBookmarks = true;
    OfferToSaveLogins = false;

    SkipTermsOfUse = true;

    EnableTrackingProtection = lockedAs true {
      Value = true;
      Locked = true;
      Cryptomining = true;
      Fingerprinting = true;
    };

    UserMessaging = locked {
      ExtensionRecommendations = false;
      FeatureRecommendations = false;
      FirefoxLabs = false;
      MoreFromMozilla = false;
      SkipOnboarding = true;
    };

    FirefoxSuggest = locked {
      ImproveSuggest = false;
      SponsoredSuggestions = false;
      WebSuggestions = false;
    };

    ExtensionSettings = {
      "uBlock0@raymondhill.net" = installPublished "ublock-origin";
      "wappalyzer@crunchlabz.com" = installPublished "wappalyzer";
      "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = installPublished "refined-github-";
      "{85860b32-02a8-431a-b2b1-40fbd64c9c69}" = installPublished "github-file-icons";
      "{446900e4-71c2-419f-a6a7-df9c091e268b}" = installPublished "bitwarden-password-manager";
    };

    SearchEngines = {
      Default = "Google";
      PreventInstalls = true;

      Remove = [
        "Google"
        "Bing"
        "DuckDuckGo"
        "Wikipedia (en)"
      ];

      Add = [
        {
          Name = "Google";
          Alias = "gg";
          Method = "GET";
          URLTemplate = "https://google.com/search?q={searchTerms}";
          SuggestURLTemplate = "https://google.com/complete/search?client=firefox&q={searchTerms}";
        }
        {
          Name = "GitHub";
          Alias = "gh";
          Method = "GET";
          URLTemplate = "https://github.com/search?type=repositories&q={searchTerms}";
        }
        {
          Name = "Sourcegraph";
          Alias = "sg";
          Method = "GET";
          URLTemplate = "https://sourcegraph.com/search?q=context:global+{searchTerms}";
        }
      ];
    };
  };
in
{
  home.sessionVariables.BROWSER = "chromium";
}
