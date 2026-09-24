{ pkgs, ... }:
let
  tomlFormat = pkgs.formats.toml { };
in
{
  home.packages = [ pkgs.herdr ];

  home.file.".config/herdr/config.toml".source = tomlFormat.generate "herdr-config" {
    onboarding = false;

    theme = {
      name = "catppuccin";
      auto_switch = false;
    };

    ui = {
      agent_panel_sort = "spaces";
      show_agent_labels_on_pane_borders = false;
    };

    keys = {
      prefix = "ctrl+g";
      previous_agent = "prefix+shift+a";
      next_agent = "prefix+a";
      focus_agent = "prefix+shift+1..9";
      previous_workspace = "prefix+u";
      next_workspace = "prefix+i";
      navigate_workspace_up = "k";
      navigate_workspace_down = "j";
    };
  };
}
