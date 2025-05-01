{
  programs.zsh.enable = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults.NSGlobalDomain.NSWindowShouldDragOnGesture = true;
  system.defaults.CustomSystemPreferences."com.apple.AdLib" = {
    allowApplePersonalizedAdvertising = false;
    allowIdentifierForAdvertising = false;
    forceLimitAdTracking = true;
    personalizedAdsMigrated = false;
  };
}
