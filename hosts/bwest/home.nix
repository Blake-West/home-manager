{ inputs, ... }:
{
  home.username = "bwest";
  home.homeDirectory = "/home/bwest";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # Non-NixOS Ubuntu host.
  targets.genericLinux.enable = true;

  # GPU wrapping for OpenGL apps (ghostty). RTX 2000 Ada -> proprietary Nvidia
  # wrapper, which reads /proc/driver/nvidia/version at build time, so every
  # build/switch must pass --impure. Provides config.lib.nixGL.wrap, consumed
  # by modules/ghostty.nix.
  targets.genericLinux.nixGL = {
    packages = inputs.nixgl.packages;
    defaultWrapper = "nvidia";
    installScripts = [ "nvidia" ];
  };
}
