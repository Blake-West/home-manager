{ config, pkgs, ... }:
{
  # neovim itself is nix-managed; the config is NOT copied into the store.
  # ~/.config/nvim points at the live git checkout so lazy.nvim keeps managing
  # plugins and lazy-lock.json stays mutable (:Lazy update works in place).
  home.packages = [ pkgs.neovim ];

  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nvim";
}
