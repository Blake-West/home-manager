{ config, pkgs, ... }:
{
  # Symbola covers the Unicode media-control block (U+23E9-U+23FA: ⏵ ⏸ ⏩ ...)
  # that JetBrainsMono Nerd Font lacks, so the ghostty fallback chain below can
  # render glyphs like the ⏵⏵ "accept edits" indicator.
  home.packages = [ pkgs.symbola ];

  # On non-NixOS, this links profile fonts into ~/.local/share/fonts (an
  # xdg dir the system /etc/fonts/fonts.conf already scans) so Symbola above is
  # visible to fontconfig, and thus to ghostty's fallback resolution.
  fonts.fontconfig.enable = true;

  programs.ghostty = {
    enable = true;

    # nixGL-wrap for OpenGL/EGL access on this non-NixOS Nvidia machine. This
    # also rewrites the generated .desktop Exec, so the hand-written
    # ~/.local/bin/ghostty wrapper and desktop launcher become obsolete.
    package = config.lib.nixGL.wrap pkgs.ghostty;

    settings = {
      theme = "Catppuccin Mocha";
      # Primary text font first; Symbola is consulted only for glyphs JetBrains
      # is missing (fallback order, so it never restyles normal text).
      font-family = [
        "JetBrainsMono Nerd Font"
        "Symbola"
      ];
      font-size = 12;
      keybind = [
        "ctrl+alt+h=goto_split:left"
        "ctrl+alt+j=goto_split:down"
        "ctrl+alt+k=goto_split:up"
        "ctrl+alt+l=goto_split:right"
        "ctrl+shift+j=previous_tab"
        "ctrl+shift+k=next_tab"
      ];
    };
  };
}
