{
  inputs,
  pkgs,
  ...
}: {
  homebrew = {
    enable = true;
    global = {
      autoUpdate = false;
    };
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
    };
    # need to do this since mise ruby plugin
    # builds ruby binary from scratch
    brews = [
      "gmp"
      "libyaml"
      "openssl@3"
      "openssl@1.1"
      "readline"

      "gawk"
      "readline"
      "xz"
      "zlib"

      "pinentry-mac"

      "watchman"
    ];
    casks = [
      "1password"
      "1password-cli"
      "android-studio"
      "arc"
      "bettertouchtool"
      "boop"
      "cleanmymac"
      "commandq"
      "cyberduck"
      "eloston-chromium"
      "handbrake"
      "karabiner-elements"
      "keepingyouawake"
      "komet"
      "macs-fan-control"
      "minisim"
      "orbstack"
      "raycast"
      "tableplus"
      "the-unarchiver"
      "topnotch"
      "viscosity"
      "visual-studio-code"
    ];
  };

  users.users.maman = {
    home = "/Users/maman";
    shell = pkgs.fish;
  };

  security.pam.enableSudoTouchIdAuth = true;

  system = {
    stateVersion = 4;
    keyboard.enableKeyMapping = true;
    keyboard.remapCapsLockToEscape = true;

    defaults = {
      CustomUserPreferences = {
        "com.apple.finder" = {
          "_FXSortFoldersFirst" = true;
        };
      };
      alf.globalstate = 1;
      alf.loggingenabled = 0;
      alf.stealthenabled = 1;
      alf.allowsignedenabled = 1;
      alf.allowdownloadsignedenabled = 0;
      dock.autohide = true;
      dock.mru-spaces = false;
      dock.enable-spring-load-actions-on-all-items = true;
      dock.expose-group-by-app = false;
      dock.show-process-indicators = false;
      dock.show-recents = false;
      dock.minimize-to-application = true;
      dock.mineffect = "scale";
      dock.autohide-time-modifier = 0.1;
      dock.autohide-delay = 0.1;
      finder.AppleShowAllExtensions = true;
      finder.FXDefaultSearchScope = "SCcf";
      finder.FXEnableExtensionChangeWarning = false;
      NSGlobalDomain."com.apple.springing.delay" = 0.0;
      NSGlobalDomain."com.apple.springing.enabled" = true;
      NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = true;
      NSGlobalDomain.ApplePressAndHoldEnabled = false;
      NSGlobalDomain.AppleScrollerPagingBehavior = true;
      NSGlobalDomain."com.apple.keyboard.fnState" = true;
      NSGlobalDomain.InitialKeyRepeat = 10;
      NSGlobalDomain.KeyRepeat = 5;
      NSGlobalDomain.NSUseAnimatedFocusRing = false;
      NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
      NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
      NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
      screensaver.askForPassword = true;
      screensaver.askForPasswordDelay = 0;
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
    };
  };
}
