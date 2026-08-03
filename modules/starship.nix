{ ... }:
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      format = "$username$hostname$time$directory$git_branch$git_status$all$line_break$character";

      username = {
        style_user = "bold blue";
        style_root = "bold red";
        format = "[$user]($style)";
        disabled = false;
        show_always = true;
      };

      hostname = {
        ssh_only = false;
        format = "@[$hostname](bold green) ";
        disabled = false;
      };

      time = {
        disabled = false;
        format = "[$time](bold yellow) ";
        time_format = "%H:%M:%S";
      };

      directory = {
        style = "bold cyan";
        format = "[$path]($style) ";
        truncation_length = 2;
        truncate_to_repo = false;
        truncation_symbol = "…/";
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
        format = "on[$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold red";
        format = "[$all_status$ahead_behind]($style) ";
        conflicted = "⚡";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        up_to_date = "";
        untracked = "?\${count}";
        stashed = "\$\${count}";
        modified = "!\${count}";
        staged = "+\${count}";
        renamed = "»\${count}";
        deleted = "✘\${count}";
      };

      # Default ❄️ is U+2744 + VS16 (U+FE0F), which forces emoji presentation
      # only Noto Color Emoji satisfies. The monospace fallback chain (JetBrains
      # then Symbola) has no emoji-presentation font, so it renders as tofu.
      # Use the monochrome NixOS Nerd Font glyph instead, matching git_branch.
      nix_shell = {
        symbol = " ";
        format = "via [$symbol$state]($style) ";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vicmd_symbol = "[❮](bold yellow)";
      };
    };
  };
}
