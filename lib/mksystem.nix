{
  nixpkgs,
  overlays,
  inputs,
}: name: {
  system,
  user,
  darwin ? false,
  wsl ? false,
  chromeos ? false,
}: let
  isWSL = wsl;
  isChromeOS = chromeos;
  machineConfig = ../machines/${name}.nix;
  userOSConfig =
    ../users/${user}/${
      if darwin
      then "darwin"
      else "nixos"
    }.nix;
  userHMConfig = ../users/${user}/home-manager.nix;

  systemFunc =
    if darwin
    then inputs.darwin.lib.darwinSystem
    else nixpkgs.lib.nixosSystem;
  home-manager =
    if darwin
    then inputs.home-manager.darwinModules
    else inputs.home-manager.nixosModules;
  nix-homebrew =
    if darwin
    then inputs.nix-homebrew.darwinModules
    else {};
in
  systemFunc rec {
    inherit system;

    modules =
      [
        {nixpkgs.overlays = overlays;}

        (
          if isWSL
          then inputs.nixos-wsl.nixosModules.wsl
          else {}
        )

        machineConfig
        userOSConfig
        home-manager.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user} = import userHMConfig {
            isWSL = isWSL;
            isChromeOS = isChromeOS;
            inputs = inputs;
          };
        }

        {
          config._module.args = {
            currentSystem = system;
            currentSystemName = name;
            currentSystemUser = user;
            isWSL = isWSL;
            isChromeOS = isChromeOS;
            inputs = inputs;
          };
        }
      ]
      ++ (nixpkgs.lib.optionals darwin [
        nix-homebrew.nix-homebrew
        {
          nix-homebrew.enable = true;
          nix-homebrew.user = "maman";
          nix-homebrew.taps = {
            "homebrew/homebrew-core" = inputs.homebrew-core;
            "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
            "homebrew/homebrew-cask" = inputs.homebrew-cask;
          };
          nix-homebrew.mutableTaps = false;
        }
      ]);
  }
