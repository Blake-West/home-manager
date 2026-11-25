{ pkgs, ... }:
let
  amixer = "${pkgs.alsa-utils}/bin/amixer";

  # The dongle's hardware PCM volumes come up at arbitrary low levels
  # (~-12/-24 dB). The desktop volume slider drives these same controls, so
  # only raise them to max once each time the dongle appears (login/replug),
  # never while it stays connected, so manual adjustments stick. Does nothing
  # when the dongle is absent, so it's inert on other hosts.
  maxVolume = pkgs.writeShellScript "audeze-max-volume" ''
    present=0
    while true; do
      if ${amixer} -c Dongle info >/dev/null 2>&1; then
        if [ "$present" = 0 ]; then
          for idx in 0 1; do
            ${amixer} -q -c Dongle cset "iface=MIXER,name='PCM Playback Volume',index=$idx" 73,73 || true
          done
          present=1
        fi
      else
        present=0
      fi
      sleep 10
    done
  '';
in
{
  # Audeze Maxwell dongle exposes two USB playback devices (hw:N,0 = Chat + mic,
  # hw:N,1 = Game), but PipeWire's default ACP profile only maps device 0.
  # Use PipeWire's gaming-headset profile-set so "Game" and "Chat" show up as
  # separate sinks, and make Game the preferred default output.
  #
  # Rules match only this dongle's device/node names, so they are inert on
  # machines without it (safe for the work flake that imports this module).
  xdg.configFile."wireplumber/wireplumber.conf.d/51-audeze-maxwell.conf".text = ''
    monitor.alsa.rules = [
      {
        matches = [
          { "device.name" = "~alsa_card.usb-Audeze_LLC_Audeze_Maxwell_Dongle*" }
        ]
        actions = {
          update-props = {
            "device.profile-set" = "usb-gaming-headset.conf"
            "api.alsa.use-acp" = true
          }
        }
      }
      {
        matches = [
          { "node.name" = "alsa_output.usb-Audeze_LLC_Audeze_Maxwell_Dongle_0000000000000000-01.stereo-game" }
        ]
        actions = {
          update-props = {
            "node.description" = "Audeze Maxwell Game"
            "priority.session" = 3000
            "priority.driver" = 3000
          }
        }
      }
      {
        matches = [
          { "node.name" = "alsa_output.usb-Audeze_LLC_Audeze_Maxwell_Dongle_0000000000000000-01.stereo-chat" }
        ]
        actions = {
          update-props = {
            "node.description" = "Audeze Maxwell Chat"
          }
        }
      }
    ]
  '';

  systemd.user.services.audeze-max-volume = {
    Unit.Description = "Pin Audeze Maxwell dongle hardware volume to max";
    Service = {
      ExecStart = "${maxVolume}";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
