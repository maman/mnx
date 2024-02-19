{
  isWSL,
  isChromeOS,
  inputs,
  ...
}: {
  config,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  # Get brew prefix path
  platformConfig =
    if isDarwin
    then config.darwinConfigurations
    else config.nixosConfigurations;
  brewPrefix = platformConfig.${builtins.getEnv "USER"}.homebrew.brewPrefix;
in {
  # mise isn't on home-manager stable yet
  imports = [
    ../../modules/home-manager/mise.nix
  ];

  home.stateVersion = "23.11";
  xdg.enable = true;

  home.packages =
    [
      inputs.alejandra.defaultPackage.${pkgs.stdenv.hostPlatform.system}

      pkgs.aria2
      pkgs.bat
      pkgs.fd
      pkgs.fzf
      pkgs.git
      pkgs.gnupg
      pkgs.gnutar
      pkgs.grc
      pkgs.jq
      pkgs.mosh
      pkgs.nixd
      pkgs.ripgrep
      pkgs.tree
      pkgs.watch
      pkgs.htop
      pkgs.neovim
      pkgs.zellij
    ]
    ++ (lib.optionals isDarwin [
      pkgs.cachix
      pkgs.xcodes
    ])
    ++ (lib.optionals isLinux [
      pkgs.pinentry
      pkgs.chromium
      pkgs.watchman
    ]);

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
  };

  programs.bash = {
    enable = true;
    shellOptions = ["autocd" "histappend" "checkwinsize"];
    historyControl = ["ignoredups" "ignorespace"];
    enableCompletion = true;
  };
  programs.fish = {
    enable = true;
    shellAliases =
      {
        vim = "nvim";
      }
      // (
        if isLinux
        then {
          pbcopy = "xclip";
          pbpaste = "xclip -o";
        }
        else {}
      );
    plugins = [
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "hydro";
        src = pkgs.fishPlugins.hydro.src;
      }
    ];
    shellInit = ''
      set -U fish_greeting
    '';
    loginShellInit = let
      dquote = str: "\"" + str + "\"";
      makeBinPathList = map (path: path + "/bin");
    in ''
      fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList osConfig.environment.profiles)}
      set fish_user_paths $fish_user_paths
    '';
  };
  programs.zsh = {
    enable = true;
  };
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.ssh =
    {
      enable = true;
    }
    // (
      if isDarwin
      then {
        extraConfig = ''
          IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        '';
        extraOptionOverrides = {
          Include = "~/.orbstack/ssh/config";
        };
      }
      else {}
    );
  programs.git = {
    enable = true;
    userName = "Achmad Mahardi";
    userEmail = "achmad@mahardi.me";
    extraConfig =
      {
        color.ui = true;
        github.user = "maman";
        init.defaultBranch = "main";
      }
      // (
        if isDarwin
        then {
          user.signingkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOIA9EHKkuO0ivO3P/5ClodR/FO3ElPI7xBGUh43EyC5dUoTRcAknErdPAgnE8hAkgk2EkboE+PLuSZifyXqeeW5REsVQ7UKbXiujpIEtFh78cv3Rue0JdIl2DsSqRSdWIaCoIo4BsSPoThFBOtNXsaVcmJIkqZa60Urcw1rsmoVtcgP3N0DZ0NjWCo8GQPo1OjB9Aq5YNJ6pqNr3Eb4P/TMRcsr64UaN67JLaQji4Jbdwk/BG9p/xwF++HCQIuLycwFNaR5MvhK0CLJWe/KYTgp6404L1rT154f9N7CFklAfccy1lMFnscKyMPBH5Eq2OZu4jXm1hfwWGecLr3AXA7dFQcxersrL/ou3z9yXgLpMB90xSv9JdN4IbZU6g3bs1tQr/JOJr8SurIRANGn56e+SRbCBS3QsMlD8ZN2Ur2LU1b9TqF/ErAx/ipdHHw9JVlYzgcBuia87C61n9G6qPUDCBqIhHpoAHCOoY3PPPxozTgW1u9TJvF60PTBfaMRddxOAeDJzTyqq7Ncxp6J8IRn+Hx6hJLhSPNnBTEohxy22mikY3Wq2TrfqkrSxwoF7EMC9tDpGHgSe4io3zjxz6RnRt0euZQF9iuWg5BtA0TplA0DU5DgN902ut7IXOgVv6PEJUuiF0gYmnU+GvW7KmMMBuCV5jEqAYfan0mkRVIQ==";
          gpg.format = "ssh";
          "gpg \"ssh\"".program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          commit.gpgsign = true;
          core.editor = "/Applications/Komet.app/Contents/MacOS/Komet";
        }
        else {}
      );
  };
  programs.go = {
    enable = true;
    goPath = "Code/go";
  };
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };
  services.gpg-agent =
    {
      enable = !isDarwin;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    }
    // (
      if isDarwin
      then {
        extraConfig = ''
          pinentry-program ${brewPrefix}/bin/pinentry-mac
        '';
      }
      else {}
    );
  programs.mise = {
    enable = true;
    package = pkgs.unstable.mise;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    globalConfig = {
      tools = {
        adb = "latest";
        node = "lts";
        python = "3.11.7";
        github-cli = "latest";
        kubectl = "1.24";
        kubectx = "latest";
        awscli = "latest";
        java = "openjdk-19";
        go = "1.22.0";
        deno = "latest";
        bun = "latest";
        flyctl = "0.1.147";
        "npm:@withgraphite/graphite-cli" = "latest";
      };
      plugins = {
        adb = "https://github.com/vic/asdf-link.git";
      };
      settings = {
        experimental = true;
      };
    };
  };

  home.file = {
    ".hushlogin".text = "";
    # ".CFUserTextEncoding".text = "0x08000100:0";
  };
}
