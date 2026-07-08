{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    settings = {
      # Personal identity is the public default. The work flake overrides
      # user.email (and adds the ghe credential helper) via work-git.nix.
      user = {
        name = "Blake West";
        email = "Blake.R.West@gmail.com";
      };

      push = {
        autoSetupRemote = true;
        default = "current";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
    };

    ignores = [
      "**/.claude/settings.local.json"
      ".tmp/"
      "tmp/"
    ];

    # Runs `nix fmt` on staged files when the repo is a flake, then re-stages
    # anything the formatter changed.
    hooks.pre-commit = pkgs.writeShellScript "git-pre-commit" ''
      #!/usr/bin/env bash
      repo_root="$(git rev-parse --show-toplevel)"

      if [ -f "$repo_root/flake.nix" ]; then
          staged=$(git diff --cached --name-only --diff-filter=ACMR)
          [ -z "$staged" ] && exit 0

          nix fmt 2>/dev/null

          restaged=0
          while IFS= read -r f; do
              if [ -n "$f" ] && ! git diff --quiet -- "$f"; then
                  git add -- "$f"
                  restaged=1
              fi
          done <<< "$staged"

          if [ "$restaged" = 1 ]; then
              echo "nix fmt made changes, staging formatted files"
          fi
      fi

      exit 0
    '';
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      aliases.co = "pr checkout";
    };
  };
}
