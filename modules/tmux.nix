{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    mouse = true;
    keyMode = "vi";
    terminal = "tmux-256color";

    # Plugins declaratively via nix, replacing runtime TPM. Catppuccin is NOT a
    # plugin here: the status bar below is hand-crafted, so the catppuccin
    # plugin would only fight it.
    plugins = [
      {
        plugin = pkgs.tmuxPlugins.resurrect;
        # This nixpkgs build defaults to the legacy ~/.tmux/resurrect. Pin it to
        # the XDG path where the pre-migration history (and continuum saves) live.
        extraConfig = ''
          set -g @resurrect-dir '~/.local/share/tmux/resurrect'
        '';
      }
      {
        plugin = pkgs.tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
        '';
      }
      pkgs.tmuxPlugins.fzf-tmux-url
    ];

    extraConfig = ''
      # prefix send-through
      bind-key C-a send-prefix

      # Slow down mouse scrolling (2 lines per tick instead of default 5)
      bind-key -T copy-mode-vi WheelUpPane send-keys -X -N 2 scroll-up
      bind-key -T copy-mode-vi WheelDownPane send-keys -X -N 2 scroll-down

      # Splits and new windows open in the current pane's directory
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Switch panes using Prefix+h/j/k/l
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Resize panes using Prefix+H/J/K/L (repeatable with -r)
      bind-key -r H resize-pane -L 5
      bind-key -r J resize-pane -D 5
      bind-key -r K resize-pane -U 5
      bind-key -r L resize-pane -R 5

      set -ga terminal-overrides ",xterm-256color:Tc" # For true color support
      set -ga terminal-overrides ',*:Ss=\E[%p1%d q:Se=\E[2 q' # Cursor shape passthrough

      # Pass through extended keys (Shift+Enter, etc.) and allow apps like Claude
      # Code to own the alternate screen so their internal scrollback works.
      set -g allow-passthrough on
      set -s extended-keys on
      set -as terminal-features 'xterm*:extkeys'

      # Scrolloff in copy mode (5-line buffer top and bottom, matching vim scrolloff=5)
      bind-key -T copy-mode-vi j if-shell -F "#{&&:#{e|>=|:#{copy_cursor_y},#{e|-|:#{pane_height},6}},#{e|>|:#{scroll_position},0}}" {
          send-keys -X scroll-down
      } {
          send-keys -X cursor-down
      }
      bind-key -T copy-mode-vi k if-shell -F "#{&&:#{e|<=|:#{copy_cursor_y},5},#{e|<|:#{scroll_position},#{history_size}}}" {
          send-keys -X scroll-up
      } {
          send-keys -X cursor-up
      }

      # Forward focus events to applications (needed for neovim autoread)
      set -g focus-events on

      # ============================================================
      # Catppuccin Mocha Status Bar
      # ============================================================
      # Palette reference:
      #   Crust=#11111b  Mantle=#181825  Base=#1e1e2e
      #   Surface0=#313244  Surface1=#45475a  Surface2=#585b70
      #   Overlay0=#6c7086  Subtext0=#a6adc8  Text=#cdd6f4
      #   Blue=#89b4fa  Lavender=#b4befe  Sky=#89dceb
      #   Green=#a6e3a1  Yellow=#f9e2af  Mauve=#cba6f7

      set -g status on
      set -g status-interval 5
      set -g status-position bottom
      set -g status-justify left
      set -g status-style "bg=#181825,fg=#cdd6f4"

      set -g status-left-length 40
      set -g status-right-length 120

      set -g status-left "#[fg=#11111b,bg=#89b4fa,bold]  #S #[fg=#89b4fa,bg=#181825,nobold]"

      set -g status-right "\
      #[fg=#45475a,bg=#181825]\
      #[fg=#a6e3a1,bg=#45475a]  #(~/.config/tmux/scripts/cpu.sh) \
      #[fg=#585b70,bg=#45475a]\
      #[fg=#f9e2af,bg=#585b70]  #(~/.config/tmux/scripts/ram.sh) \
      #[fg=#45475a,bg=#585b70]\
      #[fg=#89dceb,bg=#45475a] #(~/.config/tmux/scripts/weather.sh) \
      #[fg=#b4befe,bg=#45475a]\
      #[fg=#11111b,bg=#b4befe]  %d %b \
      #[fg=#89b4fa,bg=#b4befe]\
      #[fg=#11111b,bg=#89b4fa,bold]  %H:%M "

      set -g window-status-format "#[fg=#181825,bg=#313244]#[fg=#a6adc8,bg=#313244] #I:#W #[fg=#313244,bg=#181825]"
      set -g window-status-current-format "#[fg=#181825,bg=#cba6f7]#[fg=#11111b,bg=#cba6f7,bold] #I:#W #[fg=#cba6f7,bg=#181825]"
      set -g window-status-separator ""

      set -g pane-border-style "fg=#45475a"
      set -g pane-active-border-style "fg=#cba6f7"

      set -g message-style "bg=#313244,fg=#cdd6f4"
      set -g message-command-style "bg=#313244,fg=#cdd6f4"

      set -g clock-mode-colour "#89b4fa"
      set -g clock-mode-style 24

      set -g mode-style "bg=#585b70,fg=#cdd6f4"
    '';
  };

  # Status-bar helper scripts, migrated from the old ~/.config/tmux/scripts/.
  home.file.".config/tmux/scripts/cpu.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      top -bn1 | awk '/^%?Cpu/{gsub(/,/,".",$2); printf "%.0f%%", $2}'
    '';
  };

  home.file.".config/tmux/scripts/ram.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      free -h | awk '/^Mem:/{print $3 "/" $2}'
    '';
  };

  home.file.".config/tmux/scripts/weather.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      LOCATION="Atlanta+GA"
      CACHE_FILE="/tmp/tmux-weather-cache"
      CACHE_MAX_AGE=1800
      if [ -f "$CACHE_FILE" ]; then
        file_age=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
        if [ "$file_age" -lt "$CACHE_MAX_AGE" ]; then
          cat "$CACHE_FILE"
          exit 0
        fi
      fi
      weather=$(curl -s --noproxy '*' --max-time 5 "wttr.in/''${LOCATION}?format=%c+%t&u" 2>/dev/null | tr -d '+')
      if [ -n "$weather" ] && [ "$weather" != "Unknown" ]; then
        echo "$weather" > "$CACHE_FILE"
        echo "$weather"
      else
        [ -f "$CACHE_FILE" ] && cat "$CACHE_FILE" || echo "N/A"
      fi
    '';
  };
}
