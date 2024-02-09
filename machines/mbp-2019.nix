{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.nix-index.enable = true;
  nix.useDaemon = true;
  nix = {
    extraOptions =
      ''
        build-users-group = nixbld
        experimental-features = nix-command flakes repl-flake
        bash-prompt-prefix = (nix:$name)\040
        max-jobs = auto
        extra-nix-path = nixpkgs=flake:nixpkgs
        keep-outputs = true
        keep-derivations = true
        #upgrade-nix-store-path-url = https://install.determinate.systems/nix-upgrade/stable/universal
      ''
      + lib.optionalString (pkgs.system == "aarch64-darwin") ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';
    settings = {
      auto-optimise-store = true;
      substituters = ["https:cache.komunix.org/"];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  programs.zsh.enable = true;
  programs.zsh.shellInit = ''
    # Nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    # End Nix
  '';

  programs.fish.enable = true;
  programs.fish.shellInit = ''
    # Nix
    if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
    end
    # End Nix
  '';

  environment.shells = with pkgs; [bashInteractive zsh fish];
  environment.systemPackages = with pkgs; [
    cachix
  ];
}
