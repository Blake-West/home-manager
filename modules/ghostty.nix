{ config, pkgs, ... }:
{
  programs.ghostty = {
    enable = true;

    # nixGL-wrap for OpenGL/EGL access on this non-NixOS Nvidia machine. This
    # also rewrites the generated .desktop Exec, so the hand-written
    # ~/.local/bin/ghostty wrapper and desktop launcher become obsolete.
    package = config.lib.nixGL.wrap pkgs.ghostty;

    settings = {
      theme = "Catppuccin Mocha";
      font-family = "JetBrainsMono Nerd Font";
      font-size = 14;
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
