{ ... }:
{
  programs.bash = {
    enable = true;

    historyControl = [ "ignoreboth" ];
    historySize = 10000;
    historyFileSize = 100000;
    shellOptions = [
      "histappend"
      "checkwinsize"
    ];

    # Personal aliases only. Context-specific aliases are layered in by a
    # separate private overlay, not this public config.
    shellAliases = {
      vi = "nvim";
      vim = "nvim";

      # ls/grep colors. bash expands the ls alias recursively, so ll/la/l
      # inherit --color too. LS_COLORS comes from programs.dircolors below.
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";

      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";

      cl = "git clone";
      pl = "git pull";
      pu = "git push";
      br = "git branch";
      ch = "git checkout";
      fe = "git fetch";
      me = "git merge";
      st = "git status";
      ad = "git add";
      co = "git commit";

      sourceme = "source ~/.bashrc";
      nix_218 = ''nix --builders "" run github:NixOS/nixpkgs/release-23.11#nixVersions.nix_2_18 -- --builders ""'';

      # Desktop notification when a long-running command finishes: `sleep 10; alert`
      alert = ''notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'';
    };

    initExtra = ''
      # Make `less` handle non-text input (archives, etc.) via the system lesspipe
      [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh /usr/bin/lesspipe)"

      # vi mode with jk chord to leave insert
      set -o vi
      bind -m vi-insert '"jk": vi-movement-mode'

      # NVM (no home-manager module; kept as a standalone checkout in ~/.nvm)
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

      # home-manager switcher: work config when its checkout is present, else personal.
      # --impure + NIXPKGS_ALLOW_UNFREE: the Nvidia nixGL wrapper reads the running
      # driver version and pulls the unfree nvidia-x11 driver, both at eval time.
      hms() {
        local work_flake="$HOME/Code/home-manager-work"
        if [ -f "$work_flake/flake.nix" ]; then
          NIXPKGS_ALLOW_UNFREE=1 home-manager switch --flake "$work_flake#bwest-work" --impure "$@"
        else
          NIXPKGS_ALLOW_UNFREE=1 home-manager switch --flake "$HOME/.config/home-manager#bwest" --impure "$@"
        fi
      }

      # 1% chance pokemon fortune on shell start
      if command -v fortune >/dev/null 2>&1 && command -v pokemonsay >/dev/null 2>&1; then
        if python3 -c 'import random,sys; sys.exit(0 if random.random() < 0.01 else 1)' 2>/dev/null; then
          fortune | pokemonsay -n
        fi
      fi
    '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    CDPATH = ".:$HOME/Code";
  };

  home.sessionPath = [ "$HOME/.local/bin" ];

  programs.readline = {
    enable = true;
    variables = {
      editing-mode = "vi";
      show-mode-in-prompt = true;
      completion-ignore-case = true;
      completion-map-case = true;
      show-all-if-ambiguous = true;
      # Cursor shape: block in command mode, bar in insert mode.
      vi-cmd-mode-string = ''\1\e[2 q\2'';
      vi-ins-mode-string = ''\1\e[6 q\2'';
    };
    bindings = {
      "\\e[A" = "history-search-backward";
      "\\e[B" = "history-search-forward";
    };
    # Per-keymap bindings have no structured option; keep them as raw inputrc.
    extraConfig = ''
      set keymap vi-command
      Control-r: reverse-search-history
      "k": history-search-backward
      "j": history-search-forward

      set keymap vi-insert
      Control-r: reverse-search-history
      "jk": vi-movement-mode
    '';
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  # Sets LS_COLORS (via `eval $(dircolors -b)`); the --color=auto aliases above
  # are what actually colorize ls/grep output.
  programs.dircolors = {
    enable = true;
    enableBashIntegration = true;
  };
}
