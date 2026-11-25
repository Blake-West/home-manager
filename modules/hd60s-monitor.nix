{ ... }:
{
  # Always play the Elgato HD60 S+ (Switch capture) audio through the default
  # output. Runs inside the PipeWire daemon as a loopback; it waits for the
  # capture card to appear and never falls back to another source (e.g. the
  # mic), so it cannot feed back. Personal desktop only: not in default.nix.
  xdg.configFile."pipewire/pipewire.conf.d/60-hd60s-monitor.conf".text = ''
    context.modules = [
      {
        name = libpipewire-module-loopback
        args = {
          node.description = "HD60 S+ Monitor"
          capture.props = {
            node.name = "hd60s_monitor_capture"
            target.object = "alsa_input.usb-Elgato_Game_Capture_HD60_S__0123456789000-03.analog-stereo"
            node.dont-fallback = true
            node.dont-reconnect = false
            node.passive = false
            stream.dont-remix = true
            audio.position = [ FL FR ]
          }
          playback.props = {
            node.name = "hd60s_monitor_playback"
            media.class = Stream/Output/Audio
            node.dont-reconnect = false
            audio.position = [ FL FR ]
          }
        }
      }
    ]
  '';

  # Keep the capture card from being suspended when idle.
  xdg.configFile."wireplumber/wireplumber.conf.d/52-hd60s.conf".text = ''
    monitor.alsa.rules = [
      {
        matches = [
          { "node.name" = "~alsa_input.usb-Elgato_Game_Capture_HD60_S*" }
        ]
        actions = {
          update-props = {
            "session.suspend-timeout-seconds" = 0
          }
        }
      }
    ]
  '';
}
