{ pkgs, ... }:
{
  # Personal + shared dev tooling. Work-only packages live in the work flake.
  # Omitted here on purpose: fzf/direnv/nix-direnv (installed by their
  # programs.* modules), neovim (installed by modules/nvim.nix), ghostty
  # (installed nixGL-wrapped by modules/ghostty.nix).
  home.packages = with pkgs; [
    # terminal / UI
    tmux
    chafa

    # editor ecosystem
    tree-sitter

    # nix tooling
    nil
    cachix

    # version control
    git
    gh

    # data / network
    jq
    nmap
    tshark
    chrony
    fuse2

    # language servers / formatters
    clang-tools
    rust-analyzer
    pyright

    # prompt fun
    fortune
    pokemonsay
  ];
}
