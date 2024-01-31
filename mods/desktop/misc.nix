{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
in {
  options.desktop = {
    waybar = mkEnableOption "";
    wofi = mkEnableOption "";
  };
  config = let
    inherit (config.desktop) wofi waybar;
  in {
    users.users.main.packages =
      lib.optionals wofi [pkgs.wofi]
      ++ lib.optionals waybar [pkgs.waybar];
    home.file = let
      d1 = "DP-1";
      d2 = "HDMI-A-1";
      inherit (config.colours) primary alpha;
    in {
      ".config/wofi/style.css" = mkIf wofi {
        text = ''
          #window { border: 3px solid #${primary.main}; }
          #input { margin: 15px; }
          #inner-box { margin: 0px 15px 15px 15px; }
          #entry { margin: 5px; }
          #entry:selected { color: #${primary.main}; }
        '';
      };
      ".config/waybar/config" = mkIf waybar {
        text = let
          workspaces = ''
            "sway/workspaces": {
              "disable-scroll": true,
              "all-outputs": false,
              "format": "{name}",
            }
          '';
          audio = ''
            "pulseaudio": {
              "scroll-step": 5,
              "format": "{icon}\n{format_source}",
              "format-muted": "󰝟\n{format_source}",
              "format-source": "",
              "format-source-muted": "",
              "format-icons": {
                "default": ["", ""]
              },
              "tooltip": true,
              "tooltip-format": "{volume}%"
            }
          '';
          clock = ''
            "clock": {
              "format": "{:%H\n%M}",
              "tooltip-format": "{:%Y-%m-%d}"
            }
          '';
          network = ''
            "network": {
              "format-ethernet": "󰈀",
              "format-disconnected": "",
              "tooltip-format": "{ipaddr}/{ifname}"
            }
          '';
          tray = ''
            "tray": {
              "icon-size": 16,
              "spacing": 10
            }
          '';
        in ''
          [
            {
              "layer": "bottom",
              "position": "left",
              "output": "${d1}",
              "spacing": 5,
              "margin-top": 5,
              "margin-bottom": 5,
              "modules-left": [ "sway/workspaces" ],
              "modules-right": [ "pulseaudio", "clock"],
              ${workspaces},
              ${audio},
              ${clock}
            },
            {
              "layer": "bottom",
              "position": "right",
              "output": "${d2}",
              "spacing": 5,
              "margin-top": 5,
              "margin-bottom": 5,
              "modules-left": [ "sway/workspaces" ],
              "modules-right": [ "tray", "network", "pulseaudio", "clock"],
              ${workspaces},
              ${tray},
              ${network},
              ${audio},
              ${clock}
            }
          ]
        '';
      };
      ".config/waybar/style.css" = mkIf waybar {
        text = ''
          * {
              font-family: 'Liga SFMono Nerd Font';
              font-size: 14px;
          }
          window#waybar {
              background-color: transparent;
              transition-property: background-color;
              transition-duration: .5s;
          }
          window#waybar.empty #window { background-color: transparent; }
          #workspaces {
              padding: 0px;
              border-radius: 0px;
              border:2px solid #${alpha.black};
              background-color: #${primary.bg};
              color: #${primary.fg};
          }
          #workspaces button { padding: 2px; }
          #workspaces button:hover { border-radius: 0px; }
          #workspaces button.focused { color: #${primary.main}; }
          #workspaces button.urgent { color: #${primary.main}; }
          #network,
          #pulseaudio,
          #tray,
          #clock {
              border-radius: 0px;
              border:2px solid #${alpha.black};
              background-color: #${primary.bg};
              color: #${primary.fg};
              padding: 2px;
          }
          tooltip label {
              background-color: #${primary.bg};
              color: #${primary.fg};
              border-radius: 0px;
              border:2px solid #${alpha.black};
          }
        '';
      };
    };
  };
}
