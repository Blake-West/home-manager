{ ... }:
{
  # Replaces the manual ~/.config/direnv/direnvrc and the `direnv hook bash`
  # line from the old .bashrc. nix-direnv provides fast use_nix/use_flake.
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
}
